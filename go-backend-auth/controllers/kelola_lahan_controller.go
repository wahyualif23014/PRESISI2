package controllers

import (
	"net/http"
	"strconv"
	"strings"
	"time"

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
	
	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	selectedPolres := c.Query("polres")

	queryPolres := initializers.DB.Table("wilayah w_kab").
		Where("w_kab.nama_wilayah IS NOT NULL").
		Where("CHAR_LENGTH(w_kab.id_wilayah) = 5 AND w_kab.id_wilayah LIKE '35%'")
		
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		bpsPolres := resolveTingkatToWilayah(user.IDTugas)
		if len(bpsPolres) >= 5 {
			queryPolres = queryPolres.Where("w_kab.id_wilayah = ?", bpsPolres[:5])
		} else {
			queryPolres = queryPolres.Where("w_kab.id_wilayah LIKE ?", bpsPolres+"%")
		}
	}
	
	queryPolres.Distinct("CONCAT('POLRES ', UPPER(w_kab.nama_wilayah))").
		Pluck("CONCAT('POLRES ', UPPER(w_kab.nama_wilayah))", &options.Polres)

	if selectedPolres != "" {
		namaKab := strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(selectedPolres), "POLRES", ""))
		
		queryPolsek := initializers.DB.Table("wilayah w_kec").
			Joins("LEFT JOIN wilayah w_kab ON w_kab.id_wilayah = SUBSTR(w_kec.id_wilayah,1,5)").
			Where("w_kec.nama_wilayah IS NOT NULL").
			Where("CHAR_LENGTH(w_kec.id_wilayah) = 8 AND w_kec.id_wilayah LIKE '35%'")

		queryPolsek = queryPolsek.Where("UPPER(w_kab.nama_wilayah) LIKE ?", "%"+namaKab+"%")
			
		if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
			bpsPolsek := resolveTingkatToWilayah(user.IDTugas)
			if len(bpsPolsek) >= 8 {
				queryPolsek = queryPolsek.Where("w_kec.id_wilayah = ?", bpsPolsek[:8])
			} else {
				queryPolsek = queryPolsek.Where("w_kec.id_wilayah LIKE ?", bpsPolsek+"%")
			}
		}
		
		queryPolsek.Distinct("CONCAT('POLSEK ', UPPER(w_kec.nama_wilayah))").
			Pluck("CONCAT('POLSEK ', UPPER(w_kec.nama_wilayah))", &options.Polsek)
	}

	var listJenis []string
	var uniqueJenis = make(map[string]bool)
	rows, err := initializers.DB.Table("lahan").
		Select("id_jenis_lahan").
		Group("id_jenis_lahan").
		Order("id_jenis_lahan ASC").
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
		Select("DISTINCT UPPER(nama_komoditi)").
		Order("UPPER(nama_komoditi) ASC").
		Pluck("UPPER(nama_komoditi)", &options.Komoditas)

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   options,
	})

}

func GetKelolaSummary(c *gin.Context) {
	var summary models.KelolaLahanSummary

	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	queryLahan := initializers.DB.Table("lahan")
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		queryLahan = queryLahan.Where("lahan.id_tingkat LIKE ?", user.IDTugas+"%")
	}
	queryLahan.Select("COALESCE(SUM(luas_lahan),0)").Scan(&summary.TotalPotensiLahan)

	queryTanam := initializers.DB.Table("tanam").
		Joins("JOIN lahan l ON l.id_lahan = tanam.id_lahan")
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		queryTanam = queryTanam.Where("l.id_tingkat LIKE ?", user.IDTugas+"%")
	}
	queryTanam.Select("COALESCE(SUM(luas_tanam),0)").Scan(&summary.TotalTanamLahan)

	queryPanen := initializers.DB.Table("panen").
		Joins("JOIN tanam t ON t.id_tanam = panen.id_tanam").
		Joins("JOIN lahan l ON l.id_lahan = t.id_lahan")
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		queryPanen = queryPanen.Where("l.id_tingkat LIKE ?", user.IDTugas+"%")
	}
	queryPanen.Select(`
		COALESCE(SUM(luas_panen),0),
		COALESCE(SUM(total_panen),0)
	`).Row().Scan(&summary.TotalPanenLahanHa, &summary.TotalPanenLahanTon)

	queryDistribusi := initializers.DB.Table("distribusi").
		Joins("JOIN lahan l ON l.id_lahan = distribusi.id_lahan")
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		queryDistribusi = queryDistribusi.Where("l.id_tingkat LIKE ?", user.IDTugas+"%")
	}
	queryDistribusi.Select("COALESCE(SUM(total_distribusi),0)").Scan(&summary.TotalSerapanTon)

	c.JSON(http.StatusOK, summary)

}

func GetKelolaList(c *gin.Context) {
	var result []models.KelolaLahanItem
	
	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	search := c.Query("search")
	polres := c.Query("polres")
	polsek := c.Query("polsek")
	jenisLahan := c.Query("jenis_lahan")
	komoditas := c.Query("komoditas")

	query := initializers.DB.Table("lahan").
		Select(`
			lahan.id_lahan as id,
			CONCAT('POLRES ', UPPER(w_kab.nama_wilayah), ' - POLSEK ', UPPER(w_kec.nama_wilayah)) as region_group,
			UPPER(lahan.alamat_lahan) as sub_region_group,
			COALESCE(NULLIF(lahan.cp_lahan,''), '-') as police_name,
			COALESCE(NULLIF(lahan.no_cp_lahan,''), '-') as police_phone,
			COALESCE(NULLIF(lahan.cp_polisi,''), '-') as pic_name,
			COALESCE(NULLIF(lahan.no_cp_polisi,''), '-') as pic_phone,
			COALESCE(lahan.luas_lahan, 0) as land_area,
			COALESCE(t_latest.luas_tanam, 0) as luas_tanam,
			COALESCE(CONCAT(DATE_FORMAT(t_latest.est_awal_panen, '%d/%m/%Y'), ' - ', DATE_FORMAT(t_latest.est_akhir_panen, '%d/%m/%Y')), '-') as est_panen,
			COALESCE(p_latest.luas_panen, 0) as luas_panen,
			COALESCE(p_latest.total_panen, 0) as berat_panen,
			COALESCE(d_latest.total_distribusi, 0) as serapan,
			lahan.valid_oleh IS NOT NULL as is_validated,
			CASE WHEN lahan.valid_oleh IS NOT NULL THEN 'VALIDATED' ELSE 'PENDING' END as status,
			COALESCE(CONCAT('POLRES ', UPPER(w_kab.nama_wilayah)), '-') as polres_name,
			COALESCE(CONCAT('POLSEK ', UPPER(w_kec.nama_wilayah)), '-') as polsek_name,
			CASE lahan.id_jenis_lahan
				WHEN 1 THEN 'PRODUKTIF (POKTAN BINAAN POLRI)'
				WHEN 2 THEN 'HUTAN (PERHUTANAN SOSIAL)'
				WHEN 3 THEN 'LUAS BAKU SAWAH (LBS)'
				WHEN 4 THEN 'PESANTREN'
				WHEN 5 THEN 'MILIK POLRI'
				WHEN 6 THEN 'PRODUKTIF (MASYARAKAT BINAAN POLRI)'
				WHEN 7 THEN 'PRODUKTIF (TUMPANG SARI)'
				WHEN 8 THEN 'HUTAN (PERHUTANAN/INHUTANI)'
				WHEN 9 THEN 'LAHAN TIDAK PRODUKTIF'
				ELSE 'LAHAN LAINNYA'
			END as jenis_lahan_name,
			COALESCE(lahan.keterangan_lahan, '-') as keterangan,
			COALESCE(lahan.keterangan_lahan, '-') as keterangan_lain,
			COALESCE(lahan.poktan, 0) as jml_poktan,
			COALESCE(lahan.jml_petani, 0) as jml_petani,
			COALESCE(CONCAT(k.jenis_komoditi, ' - ', k.nama_komoditi), '-') as komoditi_name,
			COALESCE(lahan.alamat_lahan, '-') as alamat_lahan,
			COALESCE(w_desa.nama_wilayah, '-') as wilayah_lahan,
			COALESCE(DATE_FORMAT(t_latest.datetransaction, '%Y-%m-%d'), '') as tgl_tanam,
			COALESCE(CAST(t_latest.id_tanam AS CHAR), '') as id_tanam,
			COALESCE(t_latest.nama_bibit, '') as jenis_bibit,
			COALESCE(t_latest.kebutuhan_bibit, 0) as kebutuhan_bibit,
			COALESCE(t_latest.surat_edit, '') as dokumen_pendukung,
			COALESCE(t_latest.keterangan_tanam, '') as keterangan_tanam,
			CASE WHEN t_latest.valid_oleh IS NOT NULL AND t_latest.valid_oleh != 0 THEN '3' ELSE '1' END as status_tanam,
			COALESCE(CAST(p_latest.id_panen AS CHAR), '') as id_panen,
			COALESCE(p_latest.status_panen, '1') as status_panen,
			COALESCE(CAST(d_latest.id_distribusi AS CHAR), '') as id_serapan,
			CASE WHEN d_latest.valid_oleh IS NOT NULL AND d_latest.valid_oleh != 0 THEN '3' ELSE '1' END as status_serapan
		`).
		Joins("LEFT JOIN wilayah w_desa ON w_desa.id_wilayah = lahan.id_wilayah").
		Joins("LEFT JOIN wilayah w_kec ON w_kec.id_wilayah = LEFT(lahan.id_wilayah, 8)").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.id_wilayah = LEFT(lahan.id_wilayah, 5)").
		Joins("LEFT JOIN komoditi k ON k.id_komoditi = lahan.id_komoditi").
		Joins(`LEFT JOIN (
			SELECT t1.* FROM tanam t1 
			INNER JOIN (SELECT id_lahan, MAX(id_tanam) as max_id FROM tanam GROUP BY id_lahan) t2 
			ON t1.id_lahan = t2.id_lahan AND t1.id_tanam = t2.max_id
		) t_latest ON t_latest.id_lahan = lahan.id_lahan`).
		Joins(`LEFT JOIN (
			SELECT p1.* FROM panen p1 
			INNER JOIN (SELECT id_lahan, MAX(id_panen) as max_id FROM panen GROUP BY id_lahan) p2 
			ON p1.id_lahan = p2.id_lahan AND p1.id_panen = p2.max_id
		) p_latest ON p_latest.id_lahan = lahan.id_lahan`).
		Joins(`LEFT JOIN (
			SELECT d1.* FROM distribusi d1 
			INNER JOIN (SELECT id_lahan, MAX(id_distribusi) as max_id FROM distribusi GROUP BY id_lahan) d2 
			ON d1.id_lahan = d2.id_lahan AND d1.id_distribusi = d2.max_id
		) d_latest ON d_latest.id_lahan = lahan.id_lahan`)

	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		query = query.Where("lahan.id_tingkat LIKE ?", user.IDTugas+"%")
	}

	if search != "" {
		s := "%" + strings.ToUpper(search) + "%"
		query = query.Where("UPPER(lahan.alamat_lahan) LIKE ? OR UPPER(lahan.poktan) LIKE ?", s, s)
	}

	if polres != "" {
		kab := strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(polres), "POLRES", ""))
		query = query.Where("UPPER(w_kab.nama_wilayah) LIKE ?", "%"+kab+"%")
	}

	if polsek != "" {
		kec := strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(polsek), "POLSEK", ""))
		query = query.Where("UPPER(w_kec.nama_wilayah) LIKE ?", "%"+kec+"%")
	}

	if komoditas != "" {
		query = query.Where("UPPER(k.nama_komoditi) = ?", strings.ToUpper(komoditas))
	}

	if jenisLahan != "" {
		mapping := map[string]int{
			"PERHUTANAN SOSIAL": 1, "POKTAN BINAAN POLRI": 2, "MASYARAKAT BINAAN POLRI": 3,
			"TUMPANG SARI": 4, "MILIK POLRI": 5, "LBS": 6, "PESANTREN": 7, "LAHAN TIDAK PRODUKTIF": 9,
		}
		if id, ok := mapping[jenisLahan]; ok {
			query = query.Where("lahan.id_jenis_lahan = ?", id)
		}
	}

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

	if err := query.Order("lahan.id_lahan DESC").Offset(offset).Limit(limit).Scan(&result).Error; err != nil {
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
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data tidak valid"})
		return
	}

	tx := initializers.DB.Begin()

	var idTanam int
	tx.Table("tanam").Select("id_tanam").Where("id_lahan = ?", idLahan).Order("id_tanam DESC").Limit(1).Scan(&idTanam)

	if idTanam > 0 {
		if err := tx.Exec(`
			UPDATE tanam 
			SET luas_tanam = ?, nama_bibit = ?, kebutuhan_bibit = ?, 
			    est_awal_panen = ?, est_akhir_panen = ?, surat_edit = ?, 
			    keterangan_tanam = ?, datetransaction = ? 
			WHERE id_tanam = ?
		`, req.LuasTanam, req.JenisBibit, req.KebutuhanBibit,
			req.EstAwalPanen, req.EstAkhirPanen, req.DokumenPendukung,
			req.Keterangan, req.TglTanam, idTanam).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		tx.Exec(`UPDATE panen SET luas_panen = ?, datetransaction = ? WHERE id_tanam = ?`,
			req.LuasTanam, req.TglTanam, idTanam)

	} else {
		if err := tx.Exec(`
			INSERT INTO tanam (id_lahan, luas_tanam, nama_bibit, kebutuhan_bibit, 
			                  est_awal_panen, est_akhir_panen, surat_edit, keterangan_tanam, datetransaction)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
		`, idLahan, req.LuasTanam, req.JenisBibit, req.KebutuhanBibit,
			req.EstAwalPanen, req.EstAkhirPanen, req.DokumenPendukung, req.Keterangan, req.TglTanam).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Data berhasil diperbarui"})
}

func DeleteKelolaLahan(c *gin.Context) {
	idLahan := c.Param("id")

	initializers.DB.Table("tanam").Where("id_lahan = ?", idLahan).Delete(nil)
	initializers.DB.Table("panen").Where("id_lahan = ?", idLahan).Delete(nil)
	initializers.DB.Table("distribusi").Where("id_lahan = ?", idLahan).Delete(nil)

	if err := initializers.DB.Table("lahan").Where("id_lahan = ?", idLahan).Delete(nil).Error; err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}
}

func ValidateTanamLahan(c *gin.Context) {
	idTanam := c.Param("id")
	var validatorID int
	if val, exists := c.Get("user"); exists {
		if user, ok := val.(models.User); ok {
			validatorID = int(user.ID)
		}
	}
	if err := initializers.DB.Exec("UPDATE tanam SET valid_oleh = ?, tgl_valid = ? WHERE id_tanam = ?", validatorID, time.Now(), idTanam).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Berhasil memvalidasi tanam"})
}

func ValidatePanenLahan(c *gin.Context) {
	idPanen := c.Param("id")
	var req struct {
		Status string `json:"status"` // '3' for Tervalidasi, '4' for Ditolak
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data tidak valid"})
		return
	}
	if err := initializers.DB.Exec("UPDATE panen SET status_panen = ? WHERE id_panen = ?", req.Status, idPanen).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Berhasil memvalidasi panen"})
}

func ValidateSerapanLahan(c *gin.Context) {
	idSerapan := c.Param("id")
	var validatorID int
	if val, exists := c.Get("user"); exists {
		if user, ok := val.(models.User); ok {
			validatorID = int(user.ID)
		}
	}
	if err := initializers.DB.Exec("UPDATE distribusi SET valid_oleh = ?, tgl_valid = ? WHERE id_distribusi = ?", validatorID, time.Now(), idSerapan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Berhasil memvalidasi serapan"})
}

type UpdatePanenReq struct {
	IdTanam         string  `json:"id_tanam"`
	LuasPanen       float64 `json:"luas_panen"`
	TotalPanen      float64 `json:"total_panen"`
	TglPanen        string  `json:"tgl_panen"`
	Keterangan      string  `json:"keterangan"`
	SuratEdit       string  `json:"surat_edit"`
}

func UpdatePanenLahan(c *gin.Context) {
	idLahan := c.Param("id")
	var req UpdatePanenReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data tidak valid"})
		return
	}
	
	tx := initializers.DB.Begin()
	var idPanen int
	tx.Table("panen").Select("id_panen").Where("id_lahan = ? AND id_tanam = ?", idLahan, req.IdTanam).Order("id_panen DESC").Limit(1).Scan(&idPanen)
	
	if idPanen > 0 {
		if err := tx.Exec(`
			UPDATE panen 
			SET luas_panen = ?, total_panen = ?, tgl_panen = ?, ket_panen = ?, surat_edit = ?, status_panen = '1' 
			WHERE id_panen = ?
		`, req.LuasPanen, req.TotalPanen, req.TglPanen, req.Keterangan, req.SuratEdit, idPanen).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	} else {
		if err := tx.Exec(`
			INSERT INTO panen (id_lahan, id_tanam, luas_panen, total_panen, tgl_panen, ket_panen, surat_edit, status_panen)
			VALUES (?, ?, ?, ?, ?, ?, ?, '1')
		`, idLahan, req.IdTanam, req.LuasPanen, req.TotalPanen, req.TglPanen, req.Keterangan, req.SuratEdit).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}
	tx.Commit()
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Data panen berhasil diperbarui"})
}

type UpdateSerapanReq struct {
	IdPanen         string  `json:"id_panen"`
	DistribusiKe    string  `json:"distribusi_ke"`
	TglDistribusi   string  `json:"tgl_distribusi"`
	TotalDistribusi float64 `json:"total_distribusi"`
	Keterangan      string  `json:"keterangan"`
	SuratEdit       string  `json:"surat_edit"`
}

func UpdateSerapanLahan(c *gin.Context) {
	idLahan := c.Param("id")
	var req UpdateSerapanReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data tidak valid"})
		return
	}
	
	tx := initializers.DB.Begin()
	var idDistribusi int
	tx.Table("distribusi").Select("id_distribusi").Where("id_lahan = ? AND id_panen = ?", idLahan, req.IdPanen).Order("id_distribusi DESC").Limit(1).Scan(&idDistribusi)
	
	if idDistribusi > 0 {
		if err := tx.Exec(`
			UPDATE distribusi 
			SET distribusi_ke = ?, tgl_distribusi = ?, total_distribusi = ?, keterangan_distribusi = ?, surat_edit = ? 
			WHERE id_distribusi = ?
		`, req.DistribusiKe, req.TglDistribusi, req.TotalDistribusi, req.Keterangan, req.SuratEdit, idDistribusi).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	} else {
		// We need to fetch id_tanam from panen
		var idTanam int
		tx.Table("panen").Select("id_tanam").Where("id_panen = ?", req.IdPanen).Scan(&idTanam)

		if err := tx.Exec(`
			INSERT INTO distribusi (id_lahan, id_panen, id_tanam, distribusi_ke, tgl_distribusi, total_distribusi, keterangan_distribusi, surat_edit)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?)
		`, idLahan, req.IdPanen, idTanam, req.DistribusiKe, req.TglDistribusi, req.TotalDistribusi, req.Keterangan, req.SuratEdit).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}
	tx.Commit()
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Data serapan berhasil diperbarui"})
}

func GetListResapan(c *gin.Context) {
	var list []string
	initializers.DB.Table("master_resapan").Select("nama").Order("id ASC").Pluck("nama", &list)
	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   list,
	})
}
