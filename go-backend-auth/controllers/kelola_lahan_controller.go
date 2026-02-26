package controllers

import (
	"net/http"
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

// ========================================================
// 1. GET FILTER OPTIONS
// ========================================================
func GetKelolaFilterOptions(c *gin.Context) {
	var options FilterOptions
	selectedPolres := c.Query("polres")

	// 1. Ambil daftar Polres
	initializers.DB.Table("lahan").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah,1,5)").
		Where("w_kab.nama IS NOT NULL").
		Distinct("CONCAT('POLRES ', UPPER(w_kab.nama))").
		Pluck("CONCAT('POLRES ', UPPER(w_kab.nama))", &options.Polres)

	// 2. Ambil daftar Polsek (Cascading)
	if selectedPolres != "" {
		namaKab := strings.TrimSpace(strings.TrimPrefix(selectedPolres, "POLRES "))
		initializers.DB.Table("lahan").
			Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah,1,5)").
			Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = SUBSTR(lahan.idwilayah,1,8)").
			Where("UPPER(w_kab.nama) = ? AND w_kec.nama IS NOT NULL", namaKab).
			Distinct("CONCAT('POLSEK ', UPPER(w_kec.nama))").
			Pluck("CONCAT('POLSEK ', UPPER(w_kec.nama))", &options.Polsek)
	}

	// 3. Ambil Jenis Lahan Dinamis
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
				title = "PERHUTANAN SOSIAL"
			case 2:
				title = "POKTAN BINAAN POLRI"
			case 3:
				title = "MASYARAKAT BINAAN POLRI"
			case 4:
				title = "TUMPANG SARI"
			case 5:
				title = "MILIK POLRI"
			case 6:
				title = "LBS"
			case 7:
				title = "PESANTREN"
			case 8:
				title = "PERHUTANI/INHUTANI"
			}

			if !uniqueJenis[title] {
				listJenis = append(listJenis, title)
				uniqueJenis[title] = true
			}
		}
		options.JenisLahan = listJenis // Pastikan dimasukkan ke struct options
	}

	// 4. Perbaikan Komoditi: Langsung masukkan ke options.Komoditas
	initializers.DB.Table("komoditi").
		Where("deletestatus = ?", "2").
		Select("DISTINCT UPPER(namakomoditi)").
		Order("UPPER(namakomoditi) ASC").
		Pluck("UPPER(namakomoditi)", &options.Komoditas) // Gunakan field dari struct options

	// Kirim Response
	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   options,
	})
}

// ========================================================
// 2. GET SUMMARY (FIXED FINAL)
// ========================================================
func GetKelolaSummary(c *gin.Context) {

	var summary models.KelolaLahanSummary

	// Total Potensi
	initializers.DB.Table("lahan").
		Select("COALESCE(SUM(luaslahan),0)").
		Scan(&summary.TotalPotensiLahan)

	// Total Tanam
	initializers.DB.Table("tanam").
		Select("COALESCE(SUM(luastanam),0)").
		Scan(&summary.TotalTanamLahan)

	// Total Panen (Ha & Ton)
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

	// Total Serapan dari distribusi
	initializers.DB.Table("distribusi").
		Select("COALESCE(SUM(totaldistribusi),0)").
		Scan(&summary.TotalSerapanTon)

	c.JSON(http.StatusOK, summary)
}

// ========================================================
// 3. GET LIST (FINAL STABLE)
// ========================================================
func GetKelolaList(c *gin.Context) {
	var result []models.KelolaLahanItem

	search := c.Query("search")
	polres := c.Query("polres")
	polsek := c.Query("polsek")
	jenisLahan := c.Query("jenis_lahan")
	komoditas := c.Query("komoditas") // <-- Tambahkan parameter ini

	query := initializers.DB.Table("lahan").
		Select(`
			lahan.idlahan as id,
			CONCAT('POLRES ', UPPER(w_kab.nama), ' - POLSEK ', UPPER(w_kec.nama)) as region_group,
			UPPER(lahan.alamat) as sub_region_group,
			COALESCE(NULLIF(lahan.cp,''), '-') as police_name,
			COALESCE(NULLIF(lahan.hp,''), '-') as police_phone,
			COALESCE(NULLIF(lahan.cppolisi,''), '-') as pic_name,
			COALESCE(NULLIF(lahan.hppolisi,''), '-') as pic_phone,
			COALESCE(lahan.luaslahan,0) as land_area,
			COALESCE(t.total_tanam,0) as luas_tanam,
			COALESCE(DATE_FORMAT(t.est_panen,'%d/%m/%Y'), '-') as est_panen,
			COALESCE(p.total_panen_ha,0) as luas_panen,
			COALESCE(p.total_panen_ton,0) as berat_panen,
			COALESCE(d.total_serapan,0) as serapan,
			lahan.validoleh IS NOT NULL as is_validated,
			CASE WHEN lahan.validoleh IS NOT NULL THEN 'VALIDATED' ELSE 'PENDING' END as status
		`).
		Joins("LEFT JOIN wilayah w_desa ON w_desa.kode = lahan.idwilayah").
		Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = LEFT(lahan.idwilayah, 8)").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = LEFT(lahan.idwilayah, 5)").
		// JOIN ke tabel komoditi agar bisa filter nama komoditas
		Joins("LEFT JOIN komoditi k ON k.idkomoditi = lahan.idkomoditi").
		Joins("LEFT JOIN (SELECT idlahan, SUM(luastanam) as total_tanam, MAX(estawalpanen) as est_panen FROM tanam GROUP BY idlahan) t ON t.idlahan = lahan.idlahan").
		Joins("LEFT JOIN (SELECT idlahan, SUM(luaspanen) as total_panen_ha, SUM(totalpanen) as total_panen_ton FROM panen GROUP BY idlahan) p ON p.idlahan = lahan.idlahan").
		Joins("LEFT JOIN (SELECT idlahan, SUM(totaldistribusi) as total_serapan FROM distribusi GROUP BY idlahan) d ON d.idlahan = lahan.idlahan")

	// --- LOGIKA FILTER ---

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

	// Filter Komoditas (Penting!)
	if komoditas != "" {
		query = query.Where("UPPER(k.namakomoditi) = ?", strings.ToUpper(komoditas))
	}

	// Filter Jenis Lahan
	if jenisLahan != "" {
		mapping := map[string]int{
			"PERHUTANAN SOSIAL": 1, "POKTAN BINAAN POLRI": 2, "MASYARAKAT BINAAN POLRI": 3,
			"TUMPANG SARI": 4, "MILIK POLRI": 5, "LBS": 6, "PESANTREN": 7,
		}
		if id, ok := mapping[jenisLahan]; ok {
			query = query.Where("lahan.idjenislahan = ?", id)
		}
	}

	if err := query.Order("lahan.datetransaction DESC").Scan(&result).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Gunakan format yang bersih agar tidak ada karakter ilegal
	for i := range result {
		if result[i].IsValidated {
			result[i].StatusColor = "#4CAF50"
		} else {
			result[i].StatusColor = "#FF9800"
		}
	}

	c.JSON(http.StatusOK, result)
}
