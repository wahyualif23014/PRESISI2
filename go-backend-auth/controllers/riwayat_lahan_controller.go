package controllers

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

func GetRiwayatSummary(c *gin.Context) {

	var summary models.RiwayatLahanSummary

	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	// ================= POTENSI =================

	queryPotensi := initializers.DB.Table("lahan l").
		Where("l.deletestatus = ?", "2").
		Where("l.status_lahan IN ?", []string{"1", "2", "3", "4"})
		
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		queryPotensi = queryPotensi.Where("l.id_tingkat LIKE ?", user.IDTugas+"%")
	}
	queryPotensi.Select("COALESCE(SUM(l.luas_lahan),0) as total").Scan(&summary.TotalPotensiLahan)

	// ================= TANAM =================

	queryTanam := initializers.DB.Table("tanam t").
		Joins("JOIN lahan l ON l.id_lahan = t.id_lahan").
		Where("t.deletestatus = ?", "2").
		Where("l.deletestatus = ?", "2")
		
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		queryTanam = queryTanam.Where("l.id_tingkat LIKE ?", user.IDTugas+"%")
	}
	queryTanam.Select("COALESCE(SUM(t.luas_tanam),0) as total").Scan(&summary.TotalTanamLahan)

	// ================= PANEN =================

	queryPanen := initializers.DB.Table("panen p").
		Joins("JOIN tanam t ON t.id_tanam = p.id_tanam").
		Joins("JOIN lahan l ON l.id_lahan = t.id_lahan").
		Where("p.deletestatus = ?", "2").
		Where("t.deletestatus = ?", "2").
		Where("l.deletestatus = ?", "2")
		
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		queryPanen = queryPanen.Where("l.id_tingkat LIKE ?", user.IDTugas+"%")
	}
	queryPanen.Select(`
			COALESCE(SUM(p.luas_panen),0) as panen_ha,
			COALESCE(SUM(p.total_panen),0) as panen_ton
		`).Row().Scan(&summary.TotalPanenLahanHa, &summary.TotalPanenLahanTon)

	// ================= SERAPAN =================

	querySerapan := initializers.DB.Table("distribusi d").
		Joins("JOIN lahan l ON l.id_lahan = d.id_lahan").
		Where("d.deletestatus = ?", "2").
		Where("l.deletestatus = ?", "2")
		
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		querySerapan = querySerapan.Where("l.id_tingkat LIKE ?", user.IDTugas+"%")
	}
	querySerapan.Select("COALESCE(SUM(d.total_distribusi),0) as total").Scan(&summary.TotalSerapanTon)

	c.JSON(http.StatusOK, summary)
}

func GetRiwayatList(c *gin.Context) {
	var result []models.RiwayatLahanItem
	
	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}
	
	search := c.Query("search")
	polres := c.Query("polres")
	polsek := c.Query("polsek")
	jenis := c.Query("jenis_lahan")
	komoditi := c.Query("komoditi")

	query := initializers.DB.Table("lahan").
		Select(`
			lahan.id_lahan as id,
			CONCAT('KAB. ', UPPER(w_kab.nama_wilayah), ' KEC. ', UPPER(w_kec.nama_wilayah), ' DESA ', UPPER(w_desa.nama_wilayah)) as region_group,
			UPPER(lahan.alamat_lahan) as sub_region_group,
			lahan.cp_polisi as police_name,
			lahan.no_cp_polisi as police_phone,
			lahan.cp_lahan as pic_name,
			lahan.no_cp_lahan as pic_phone,
			lahan.luas_lahan as land_area,

			COALESCE(t_sum.tanam_ha,0) as tanam_ha,
			'-' as est_panen,

			COALESCE(p_sum.panen_ha,0) as panen_ha,
			COALESCE(p_sum.panen_ton,0) as panen_ton,

			COALESCE(d_sum.serapan_ton,0) as serapan_ton,

			'POKTAN BINAAN POLRI' as land_category,
			'SELESAI PANEN' as status,
			'#4CAF50' as status_color
		`).
		Joins("LEFT JOIN wilayah w_desa ON w_desa.id_wilayah = lahan.id_wilayah").
		Joins("LEFT JOIN wilayah w_kec ON w_kec.id_wilayah = LEFT(lahan.id_wilayah,8)").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.id_wilayah = LEFT(lahan.id_wilayah,5)").

		// agregasi tanam
		Joins(`
		LEFT JOIN (
			SELECT id_lahan, SUM(luas_tanam) as tanam_ha
			FROM tanam
			WHERE deletestatus='2'
			GROUP BY id_lahan
		) t_sum ON t_sum.id_lahan = lahan.id_lahan
		`).

		// agregasi panen
		Joins(`
		LEFT JOIN (
			SELECT id_lahan,
			SUM(luas_panen) as panen_ha,
			SUM(total_panen) as panen_ton
			FROM panen
			WHERE deletestatus='2'
			GROUP BY id_lahan
		) p_sum ON p_sum.id_lahan = lahan.id_lahan
		`).

		// agregasi distribusi
		Joins(`
		LEFT JOIN (
			SELECT id_lahan,
			SUM(total_distribusi) as serapan_ton
			FROM distribusi
			WHERE deletestatus='2'
			GROUP BY id_lahan
		) d_sum ON d_sum.id_lahan = lahan.id_lahan
		`)
		
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		query = query.Where("lahan.id_tingkat LIKE ?", user.IDTugas+"%")
	}

	if search != "" {
		s := "%" + strings.ToUpper(search) + "%"
		query = query.Where("lahan.alamat_lahan LIKE ? OR w_desa.nama_wilayah LIKE ? OR lahan.cp_polisi LIKE ?", s, s, s)
	}

	if polres != "" {
		p := "%" + strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(polres), "POLRES", "")) + "%"
		query = query.Where("UPPER(w_kab.nama_wilayah) LIKE ?", p)
	}

	if polsek != "" {
		pk := "%" + strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(polsek), "POLSEK", "")) + "%"
		query = query.Where("UPPER(w_kec.nama_wilayah) LIKE ?", pk)
	}

	if jenis != "" {
		query = query.Where("lahan.id_jenis_lahan = ?", jenis)
	}

	if komoditi != "" {
		query = query.Joins("JOIN komoditi k ON k.id_komoditi = lahan.id_komoditi").
			Where("UPPER(k.nama_komoditi) = ?", strings.ToUpper(komoditi))
	}

	query.Scan(&result)

	c.JSON(http.StatusOK, result)
}

func normalizeWilayahName(name string) string {
	name = strings.ToUpper(name)
	name = strings.ReplaceAll(name, "KABUPATEN", "")
	name = strings.ReplaceAll(name, "KOTA", "")
	return strings.TrimSpace(name)
}

func GetRiwayatFilterOptions(c *gin.Context) {
	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	var rawPolres []string
	var rawPolsek []string

	polresParam := strings.TrimSpace(c.Query("polres"))
	searchCity := strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(polresParam), "POLRES", ""))

	queryPolres := initializers.DB.Table("wilayah").
		Select("DISTINCT UPPER(nama_wilayah) as nama_kab").
		Where("nama_wilayah IS NOT NULL").
		Where("CHAR_LENGTH(id_wilayah) = 5 AND id_wilayah LIKE '35%'")
		
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		bpsPolres := resolveTingkatToWilayah(user.IDTugas)
		if len(bpsPolres) >= 5 {
			queryPolres = queryPolres.Where("id_wilayah = ?", bpsPolres[:5])
		} else {
			queryPolres = queryPolres.Where("id_wilayah LIKE ?", bpsPolres+"%")
		}
	}
	
	queryPolres.Order("nama_kab ASC").Pluck("nama_kab", &rawPolres)

	var listPolres []string
	for _, v := range rawPolres {
		cleanName := normalizeWilayahName(v)
		listPolres = append(listPolres, fmt.Sprintf("POLRES %s", cleanName))
	}

	queryPolsek := initializers.DB.Table("wilayah w_kec").
		Select("DISTINCT UPPER(w_kec.nama_wilayah) as nama_kec").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.id_wilayah = SUBSTR(w_kec.id_wilayah,1,5)").
		Where("w_kec.nama_wilayah IS NOT NULL").
		Where("CHAR_LENGTH(w_kec.id_wilayah) = 8 AND w_kec.id_wilayah LIKE '35%'")

	if searchCity != "" {
		queryPolsek = queryPolsek.Where("UPPER(w_kab.nama_wilayah) LIKE ?", "%"+searchCity+"%")
	}
	
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		bpsPolsek := resolveTingkatToWilayah(user.IDTugas)
		if len(bpsPolsek) >= 8 {
			queryPolsek = queryPolsek.Where("w_kec.id_wilayah = ?", bpsPolsek[:8])
		} else {
			queryPolsek = queryPolsek.Where("w_kec.id_wilayah LIKE ?", bpsPolsek+"%")
		}
	}

	queryPolsek.Order("nama_kec ASC").Pluck("nama_kec", &rawPolsek)

	var listPolsek []string
	for _, v := range rawPolsek {
		listPolsek = append(listPolsek, fmt.Sprintf("POLSEK %s", strings.TrimSpace(strings.ToUpper(v))))
	}

	jenisMap := map[int]string{
		1: "PERHUTANAN SOSIAL",
		2: "POKTAN BINAAN POLRI",
		3: "MASYARAKAT BINAAN POLRI",
		4: "TUMPANG SARI",
		5: "MILIK POLRI",
		6: "LBS",
		7: "PESANTREN",
		8: "PERHUTANI/INHUTANI",
	}

	var rawJenis []int
	initializers.DB.Table("lahan").
		Select("DISTINCT id_jenis_lahan").
		Order("id_jenis_lahan ASC").
		Pluck("id_jenis_lahan", &rawJenis)

	var listJenis []string
	for _, id := range rawJenis {
		if val, ok := jenisMap[id]; ok {
			listJenis = append(listJenis, val)
		} else {
			listJenis = append(listJenis, "LAHAN LAINNYA")
		}
	}

	var rawKomoditi []string

	initializers.DB.Table("komoditi").
		Select("DISTINCT nama_komoditi").
		Where("nama_komoditi IS NOT NULL AND nama_komoditi <> ''").
		Order("nama_komoditi ASC").
		Pluck("nama_komoditi", &rawKomoditi)

	var listkomoditi []string
	for _, v := range rawKomoditi {
		listkomoditi = append(listkomoditi, strings.ToUpper(strings.TrimSpace(v)))
	}

	c.JSON(200, gin.H{
		"status": "success",
		"data": gin.H{
			"polres":      listPolres,
			"polsek":      listPolsek,
			"jenis_lahan": listJenis,
			"komoditi":    listkomoditi,
		},
	})
}
