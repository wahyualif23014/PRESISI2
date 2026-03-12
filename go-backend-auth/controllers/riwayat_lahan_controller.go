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

	// ================= POTENSI =================

	initializers.DB.Table("lahan l").
		Select(`
			COALESCE(SUM(l.luaslahan),0) as total
		`).
		Where("l.deletestatus = ?", "2").
		Where("l.statuslahan IN ?", []string{"1", "2", "3", "4"}).
		Scan(&summary.TotalPotensiLahan)

	// ================= TANAM =================

	initializers.DB.Table("tanam t").
		Select(`
			COALESCE(SUM(t.luastanam),0) as total
		`).
		Joins("JOIN lahan l ON l.idlahan = t.idlahan").
		Where("t.deletestatus = ?", "2").
		Where("l.deletestatus = ?", "2").
		Scan(&summary.TotalTanamLahan)

	// ================= PANEN =================

	initializers.DB.Table("panen p").
		Select(`
			COALESCE(SUM(p.luaspanen),0) as panen_ha,
			COALESCE(SUM(p.totalpanen),0) as panen_ton
		`).
		Joins("JOIN tanam t ON t.idtanam = p.idtanam").
		Joins("JOIN lahan l ON l.idlahan = t.idlahan").
		Where("p.deletestatus = ?", "2").
		Where("t.deletestatus = ?", "2").
		Where("l.deletestatus = ?", "2").
		Row().
		Scan(
			&summary.TotalPanenLahanHa,
			&summary.TotalPanenLahanTon,
		)

	// ================= SERAPAN =================

	initializers.DB.Table("distribusi d").
		Select(`
			COALESCE(SUM(d.totaldistribusi),0) as total
		`).
		Joins("JOIN lahan l ON l.idlahan = d.idlahan").
		Where("d.deletestatus = ?", "2").
		Where("l.deletestatus = ?", "2").
		Scan(&summary.TotalSerapanTon)

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

			COALESCE(t_sum.tanam_ha,0) as tanam_ha,
			'-' as est_panen,

			COALESCE(p_sum.panen_ha,0) as panen_ha,
			COALESCE(p_sum.panen_ton,0) as panen_ton,

			COALESCE(d_sum.serapan_ton,0) as serapan_ton,

			'POKTAN BINAAN POLRI' as land_category,
			'SELESAI PANEN' as status,
			'#4CAF50' as status_color
		`).
		Joins("LEFT JOIN wilayah w_desa ON w_desa.kode = lahan.idwilayah").
		Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = LEFT(lahan.idwilayah,8)").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = LEFT(lahan.idwilayah,5)").

		// agregasi tanam
		Joins(`
		LEFT JOIN (
			SELECT idlahan, SUM(luastanam) as tanam_ha
			FROM tanam
			WHERE deletestatus='2'
			GROUP BY idlahan
		) t_sum ON t_sum.idlahan = lahan.idlahan
		`).

		// agregasi panen
		Joins(`
		LEFT JOIN (
			SELECT idlahan,
			SUM(luaspanen) as panen_ha,
			SUM(totalpanen) as panen_ton
			FROM panen
			WHERE deletestatus='2'
			GROUP BY idlahan
		) p_sum ON p_sum.idlahan = lahan.idlahan
		`).

		// agregasi distribusi
		Joins(`
		LEFT JOIN (
			SELECT idlahan,
			SUM(totaldistribusi) as serapan_ton
			FROM distribusi
			WHERE deletestatus='2'
			GROUP BY idlahan
		) d_sum ON d_sum.idlahan = lahan.idlahan
		`)

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
		query = query.Where("lahan.idjenislahan = ?", jenis)
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
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = LEFT(lahan.idwilayah,5)").
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
		Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = LEFT(lahan.idwilayah,8)").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = LEFT(lahan.idwilayah,5)").
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
