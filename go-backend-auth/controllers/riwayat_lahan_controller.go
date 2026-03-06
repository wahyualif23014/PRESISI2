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
	initializers.DB.Table("lahan").Select("COALESCE(SUM(luaslahan), 0)").Scan(&summary.TotalPotensiLahan)
	c.JSON(http.StatusOK, summary)
}

func GetRiwayatList(c *gin.Context) {
	var result []models.RiwayatLahanItem
	search := c.Query("search")
	polres := c.Query("polres")
	polsek := c.Query("polsek")
	jenis := c.Query("jenis_lahan")
	komoditi := c.Query("komoditi")

	query := initializers.DB.Table("lahan").
		Select(`
			lahan.idlahan as id,
			CONCAT('KAB. ', UPPER(w_kab.nama), ' KEC. ', UPPER(w_kec.nama), ' DESA ', UPPER(w_desa.nama)) as region_group,
			UPPER(lahan.alamat) as sub_region_group,
			lahan.cppolisi as police_name,
			lahan.hppolisi as police_phone,
			lahan.cp as pic_name,
			lahan.hp as pic_phone,
			lahan.luaslahan as land_area,
			0.0 as tanam_ha,
			'-' as est_panen,
			0.0 as panen_ha,
			0.0 as panen_ton,
			0.0 as serapan_ton,
			'POKTAN BINAAN POLRI' as land_category,
			'SELESAI PANEN' as status,
			'#4CAF50' as status_color
		`).
		Joins("LEFT JOIN wilayah w_desa ON w_desa.kode = lahan.idwilayah").
		Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = SUBSTR(lahan.idwilayah, 1, 8)").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah, 1, 5)")

	if search != "" {
		s := "%" + strings.ToUpper(search) + "%"
		query = query.Where("lahan.alamat LIKE ? OR w_desa.nama LIKE ? OR lahan.cppolisi LIKE ?", s, s, s)
	}

	if polres != "" {
		p := "%" + strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(polres), "POLRES", "")) + "%"
		query = query.Where("UPPER(w_kab.nama) LIKE ?", p)
	}
	if polsek != "" {
		pk := "%" + strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(polsek), "POLSEK", "")) + "%"
		query = query.Where("UPPER(w_kec.nama) LIKE ?", pk)
	}
	if jenis != "" {
		query = query.Where("lahan.idjenislahan IN (SELECT idjenislahan FROM lahan WHERE land_category = ?)", jenis)
	}
	if komoditi != "" {
		query = query.Joins("JOIN komoditi k ON k.idkomoditi = lahan.idkomoditi").
			Where("UPPER(k.namakomoditi) = ?", strings.ToUpper(komoditi))
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
	var rawPolres []string
	var rawPolsek []string

	polresParam := strings.TrimSpace(c.Query("polres"))
	searchCity := strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(polresParam), "POLRES", ""))

	initializers.DB.Table("lahan").
		Select("DISTINCT UPPER(w_kab.nama) as nama_kab").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah, 1, 5)").
		Where("w_kab.nama IS NOT NULL").
		Order("nama_kab ASC").
		Pluck("nama_kab", &rawPolres)

	var listPolres []string
	for _, v := range rawPolres {
		cleanName := normalizeWilayahName(v)
		listPolres = append(listPolres, fmt.Sprintf("POLRES %s", cleanName))
	}

	queryPolsek := initializers.DB.Table("lahan").
		Select("DISTINCT UPPER(w_kec.nama) as nama_kec").
		Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = SUBSTR(lahan.idwilayah, 1, 8)").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah, 1, 5)").
		Where("w_kec.nama IS NOT NULL")

	if searchCity != "" {
		queryPolsek = queryPolsek.Where("UPPER(w_kab.nama) LIKE ?", "%"+searchCity+"%")
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
		Select("DISTINCT idjenislahan").
		Order("idjenislahan ASC").
		Pluck("idjenislahan", &rawJenis)

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
		Select("DISTINCT namakomoditi").
		Where("namakomoditi IS NOT NULL AND namakomoditi <> ''").
		Order("namakomoditi ASC").
		Pluck("namakomoditi", &rawKomoditi)

	var listkomoditi []string
	for _, v := range rawKomoditi {
		listkomoditi = append(listkomoditi,
			strings.ToUpper(strings.TrimSpace(v)))
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
