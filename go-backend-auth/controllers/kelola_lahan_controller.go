package controllers

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

type FilterOptions struct {
	Polres     []string `json:"polres"`
	Polsek     []string `json:"polsek"`
	JenisLahan []string `json:"jenis_lahan"`
	Komoditas  []string `json:"komoditas"`
}

type UpdateTanamReq struct {
	TglTanam         string  `json:"tgl_tanam"`
	LuasTanam        float64 `json:"luas_tanam"`
	JenisBibit       string  `json:"jenis_bibit"`
	KebutuhanBibit   float64 `json:"kebutuhan_bibit"`
	EstAwalPanen     string  `json:"est_awal_panen"`
	EstAkhirPanen    string  `json:"est_akhir_panen"`
	DokumenPendukung string  `json:"dokumen_pendukung"`
	Keterangan       string  `json:"keterangan"`
}

func GetKelolaFilterOptions(c *gin.Context) {
	var options FilterOptions
	selectedPolres := c.Query("polres")

	initializers.DB.Table("lahan").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah,1,5)").
		Where("w_kab.nama IS NOT NULL").
		Distinct("CONCAT('POLRES ', UPPER(w_kab.nama))").
		Pluck("CONCAT('POLRES ', UPPER(w_kab.nama))", &options.Polres)

	if selectedPolres != "" {
		namaKab := strings.TrimSpace(strings.TrimPrefix(selectedPolres, "POLRES "))
		initializers.DB.Table("lahan").
			Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah,1,5)").
			Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = SUBSTR(lahan.idwilayah,1,8)").
			Where("UPPER(w_kab.nama) = ? AND w_kec.nama IS NOT NULL", namaKab).
			Distinct("CONCAT('POLSEK ', UPPER(w_kec.nama))").
			Pluck("CONCAT('POLSEK ', UPPER(w_kec.nama))", &options.Polsek)
	}

	var listJenis []string
	var uniqueJenis = make(map[string]bool)
	rows, err := initializers.DB.Table("lahan").
		Select("idjenislahan").
		Group("idjenislahan").
		Order("idjenislahan ASC").
		Rows()

	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var id int
			rows.Scan(&id)
			title := "LAHAN LAINNYA"
			switch id {
			case 1:
				title = "PRODUKTIF (POKTAN BINAAN POLRI)"
			case 2:
				title = "HUTAN (PERHUTANAN SOSIAL)"
			case 3:
				title = "LUAS BAKU SAWAH (LBS)"
			case 4:
				title = "PESANTREN"
			case 5:
				title = "MILIK POLRI"
			case 6:
				title = "PRODUKTIF (MASYARAKAT BINAAN POLRI)"
			case 7:
				title = "PRODUKTIF (TUMPANG SARI)"
			case 8:
				title = "HUTAN (PERHUTANI/INHUTANI)"
			}

			if !uniqueJenis[title] {
				listJenis = append(listJenis, title)
				uniqueJenis[title] = true
			}
		}
		options.JenisLahan = listJenis
	}

	initializers.DB.Table("komoditi").
		Where("deletestatus = ?", "2").
		Select("DISTINCT UPPER(namakomoditi)").
		Order("UPPER(namakomoditi) ASC").
		Pluck("UPPER(namakomoditi)", &options.Komoditas)

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   options,
	})

}

func GetKelolaSummary(c *gin.Context) {
	var summary models.KelolaLahanSummary

	initializers.DB.Table("lahan").
		Select("COALESCE(SUM(luaslahan),0)").
		Scan(&summary.TotalPotensiLahan)

	initializers.DB.Table("tanam").
		Select("COALESCE(SUM(luastanam),0)").
		Scan(&summary.TotalTanamLahan)

	initializers.DB.Table("panen").
		Select(`
		COALESCE(SUM(luaspanen),0),
		COALESCE(SUM(totalpanen),0)
	`).
		Row().
		Scan(
			&summary.TotalPanenLahanHa,
			&summary.TotalPanenLahanTon,
		)

	initializers.DB.Table("distribusi").
		Select("COALESCE(SUM(totaldistribusi),0)").
		Scan(&summary.TotalSerapanTon)

	c.JSON(http.StatusOK, summary)

}

func GetKelolaList(c *gin.Context) {
	var result []models.KelolaLahanItem

	search := c.Query("search")
	polres := c.Query("polres")
	polsek := c.Query("polsek")
	jenisLahan := c.Query("jenis_lahan")
	komoditas := c.Query("komoditas")

	query := initializers.DB.Table("lahan").
		Select(`
			lahan.idlahan as id,
			CONCAT('POLRES ', UPPER(w_kab.nama), ' - POLSEK ', UPPER(w_kec.nama)) as region_group,
			UPPER(lahan.alamat) as sub_region_group,
			
			-- Hapus CONCAT agar tidak double, cukup ambil namanya saja
			COALESCE(NULLIF(lahan.cp,''), '-') as police_name,
			COALESCE(NULLIF(lahan.hp,''), '-') as police_phone,

			-- Hapus CONCAT agar tidak double, cukup ambil namanya saja
			COALESCE(NULLIF(lahan.cppolisi,''), '-') as pic_name,
			COALESCE(NULLIF(lahan.hppolisi,''), '-') as pic_phone,

			COALESCE(lahan.luaslahan, 0) as land_area,
			COALESCE(p_latest.luaspanen, 0) as luas_tanam,
			COALESCE(CONCAT(DATE_FORMAT(t_latest.estawalpanen, '%d/%m/%Y'), ' - ', DATE_FORMAT(t_latest.estakhirpanen, '%d/%m/%Y')), '-') as est_panen,

			COALESCE(p_latest.luaspanen, 0) as luas_panen,
			0 as berat_panen,
			0 as serapan,
			lahan.validoleh IS NOT NULL as is_validated,
			CASE WHEN lahan.validoleh IS NOT NULL THEN 'VALIDATED' ELSE 'PENDING' END as status,

			COALESCE(CONCAT('POLRES ', UPPER(w_kab.nama)), '-') as polres_name,
			COALESCE(CONCAT('POLSEK ', UPPER(w_kec.nama)), '-') as polsek_name,
			CASE lahan.idjenislahan
				WHEN 1 THEN 'PRODUKTIF (POKTAN BINAAN POLRI)'
				WHEN 2 THEN 'HUTAN (PERHUTANAN SOSIAL)'
				WHEN 3 THEN 'LUAS BAKU SAWAH (LBS)'
				WHEN 4 THEN 'PESANTREN'
				WHEN 5 THEN 'MILIK POLRI'
				WHEN 6 THEN 'PRODUKTIF (MASYARAKAT BINAAN POLRI)'
				WHEN 7 THEN 'PRODUKTIF (TUMPANG SARI)'
				WHEN 8 THEN 'HUTAN (PERHUTANI/INHUTANI)'
				WHEN 9 THEN 'LAHAN TIDAK PRODUKTIF'
				ELSE 'LAHAN LAINNYA'
			END as jenis_lahan_name,

			COALESCE(lahan.keterangan, '-') as keterangan,
			COALESCE(lahan.ketcp, '-') as keterangan_lain,
			COALESCE(lahan.poktan, 0) as jml_poktan,
			COALESCE(lahan.jmlsantri, 0) as jml_petani,
			COALESCE(CONCAT(k.jeniskomoditi, ' - ', k.namakomoditi), '-') as komoditi_name,
			COALESCE(lahan.alamat, '-') as alamat_lahan,
			COALESCE(w_desa.nama, '-') as wilayah_lahan,

			COALESCE(DATE_FORMAT(p_latest.datetransaction, '%Y-%m-%d'), '') as tgl_tanam,

			COALESCE(CAST(t_latest.idtanam AS CHAR), '') as id_tanam,
			COALESCE(t_latest.bibitdigunakan, '') as jenis_bibit,
			COALESCE(t_latest.kebutuhanbibit, 0) as kebutuhan_bibit,
			COALESCE(t_latest.suratedit, '') as dokumen_pendukung,
			COALESCE(t_latest.keterangan, '') as keterangan_tanam
		`).
		Joins("LEFT JOIN wilayah w_desa ON w_desa.kode = lahan.idwilayah").
		Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = LEFT(lahan.idwilayah, 8)").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = LEFT(lahan.idwilayah, 5)").
		Joins("LEFT JOIN komoditi k ON k.idkomoditi = lahan.idkomoditi").
		Joins(`LEFT JOIN (
			SELECT p1.* FROM panen p1 
			INNER JOIN (SELECT idlahan, MAX(idpanen) as max_id FROM panen GROUP BY idlahan) p2 
			ON p1.idlahan = p2.idlahan AND p1.idpanen = p2.max_id
		) p_latest ON p_latest.idlahan = lahan.idlahan`).
		Joins("LEFT JOIN tanam t_latest ON t_latest.idtanam = p_latest.idtanam")

	if search != "" {
		s := "%" + strings.ToUpper(search) + "%"
		query = query.Where("UPPER(lahan.alamat) LIKE ? OR UPPER(lahan.poktan) LIKE ?", s, s)
	}

	if polres != "" {
		kab := strings.TrimSpace(strings.TrimPrefix(polres, "POLRES "))
		query = query.Where("UPPER(w_kab.nama) = ?", kab)
	}

	if polsek != "" {
		kec := strings.TrimSpace(strings.TrimPrefix(polsek, "POLSEK "))
		query = query.Where("UPPER(w_kec.nama) = ?", kec)
	}

	if komoditas != "" {
		query = query.Where("UPPER(k.namakomoditi) = ?", strings.ToUpper(komoditas))
	}

	if jenisLahan != "" {
		mapping := map[string]int{
			"PERHUTANAN SOSIAL": 1, "POKTAN BINAAN POLRI": 2, "MASYARAKAT BINAAN POLRI": 3,
			"TUMPANG SARI": 4, "MILIK POLRI": 5, "LBS": 6, "PESANTREN": 7, "LAHAN TIDAK PRODUKTIF": 9,
		}
		if id, ok := mapping[jenisLahan]; ok {
			query = query.Where("lahan.idjenislahan = ?", id)
		}
	}
	// Ambil parameter page dan limit dari request (default: page 1, limit 50)
	page := 1
	limit := 150

	if p := c.Query("page"); p != "" {
		if parsedPage, err := strconv.Atoi(p); err == nil && parsedPage > 0 {
			page = parsedPage
		}
	}
	if l := c.Query("limit"); l != "" {
		if parsedLimit, err := strconv.Atoi(l); err == nil && parsedLimit > 0 {
			limit = parsedLimit
		}
	}

	offset := (page - 1) * limit

	// Tambahkan Offset dan Limit pada query akhir
	if err := query.Order("lahan.datetransaction DESC").Offset(offset).Limit(limit).Scan(&result).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	for i := range result {
		if result[i].IsValidated {
			result[i].StatusColor = "#4CAF50"
		} else {
			result[i].StatusColor = "#FF9800"
		}
	}

	c.JSON(http.StatusOK, result)
}

func UpdateTanamLahan(c *gin.Context) {
	idLahan := c.Param("id")
	var req UpdateTanamReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	var count int64
	initializers.DB.Table("tanam").Where("idlahan = ?", idLahan).Count(&count)

	if count > 0 {
		err := initializers.DB.Exec(`
		UPDATE tanam
		SET tglawal = ?, luastanam = ?, jenisbibit = ?, kebutuhanbibit = ?, estawalpanen = ?, estakhirpanen = ?, file = ?, keterangan = ?
		WHERE idlahan = ? ORDER BY idtanam DESC LIMIT 1
	`, req.TglTanam, req.LuasTanam, req.JenisBibit, req.KebutuhanBibit, req.EstAwalPanen, req.EstAkhirPanen, req.DokumenPendukung, req.Keterangan, idLahan).Error
		if err != nil {
			c.JSON(500, gin.H{"error": err.Error()})
			return
		}
	} else {
		err := initializers.DB.Exec(`
		INSERT INTO tanam (idlahan, tglawal, luastanam, jenisbibit, kebutuhanbibit, estawalpanen, estakhirpanen, file, keterangan, datetransaction)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
	`, idLahan, req.TglTanam, req.LuasTanam, req.JenisBibit, req.KebutuhanBibit, req.EstAwalPanen, req.EstAkhirPanen, req.DokumenPendukung, req.Keterangan).Error
		if err != nil {
			c.JSON(500, gin.H{"error": err.Error()})
			return
		}
	}
	c.JSON(200, gin.H{"message": "Berhasil memperbarui data tanam"})

}

func DeleteKelolaLahan(c *gin.Context) {
	idLahan := c.Param("id")

	initializers.DB.Table("tanam").Where("idlahan = ?", idLahan).Delete(nil)
	initializers.DB.Table("panen").Where("idlahan = ?", idLahan).Delete(nil)
	initializers.DB.Table("distribusi").Where("idlahan = ?", idLahan).Delete(nil)

	if err := initializers.DB.Table("lahan").Where("idlahan = ?", idLahan).Delete(nil).Error; err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}
	c.JSON(200, gin.H{"message": "Berhasil menghapus data lahan"})

}
