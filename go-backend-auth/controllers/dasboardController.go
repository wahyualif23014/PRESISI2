package controllers

import (
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
	"gorm.io/gorm"
)

func GetDashboardData(c *gin.Context) {

	resor := c.Query("resor")
	sektor := c.Query("sektor")
	idJenis := c.Query("id_jenis_lahan")
	idKomoditi := c.Query("id_komoditi")
	jenisKomoditi := c.Query("jenis_komoditi")
	tglMulai := c.Query("tanggal_mulai")
	tglSelesai := c.Query("tanggal_selesai")

	// Get user from context
	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	baseQuery := initializers.DB.Model(&models.Lahan{})

	// Enforce role-based scoping
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		baseQuery = baseQuery.Where("lahan.id_tingkat LIKE ?", user.IDTugas+"%")
	}

	// Filter Wilayah
	if sektor != "" {

		sName := strings.ReplaceAll(strings.ToUpper(sektor), "POLSEK ", "")

		baseQuery = baseQuery.
			Joins("LEFT JOIN wilayah w_kec ON w_kec.id_wilayah = SUBSTR(lahan.id_wilayah, 1, 8)").
			Where("UPPER(w_kec.nama_wilayah) LIKE ?", "%"+sName+"%")

	} else if resor != "" {

		rName := strings.ReplaceAll(strings.ToUpper(resor), "POLRES ", "")

		baseQuery = baseQuery.
			Joins("LEFT JOIN wilayah w_kab ON w_kab.id_wilayah = SUBSTR(lahan.id_wilayah, 1, 5)").
			Where("UPPER(w_kab.nama_wilayah) LIKE ?", "%"+rName+"%")
	}

	// Filter Jenis Lahan
	if idJenis != "" {
		baseQuery = baseQuery.Where("lahan.id_jenis_lahan = ?", idJenis)
	}

	// Get komoditi if filtered
	if idKomoditi != "" {
		baseQuery = baseQuery.Where("lahan.id_komoditi = ?", idKomoditi)
	}

	if jenisKomoditi != "" {
		baseQuery = baseQuery.Joins("JOIN komoditi ON komoditi.id_komoditi = lahan.id_komoditi").
			Where("UPPER(komoditi.jenis_komoditi) = ?", strings.ToUpper(jenisKomoditi))
	}

	// =============================
	// POTENSI LAHAN
	// =============================

	var totals struct {
		Area  float64
		Count int64
	}

	dbPotensi := baseQuery.Session(&gorm.Session{})

	err := dbPotensi.
		Where("lahan.deletestatus = ?", "2").
		Where("lahan.status_lahan IN ?", []string{"1", "2", "3", "4"}).
		Select(`
			COALESCE(SUM(luas_lahan),0) as area,
			COUNT(id_lahan) as count
		`).
		Scan(&totals).Error

	if err != nil {

		c.JSON(http.StatusInternalServerError, gin.H{
			"status":  "error",
			"message": err.Error(),
		})

		return
	}

	var response models.DashboardDataResponse

	response.ActiveFilterLabel = "TOTAL POTENSI LAHAN"

	if tglMulai != "" && tglSelesai != "" {
		response.ActiveFilterLabel = fmt.Sprintf("PERIODE %s S/D %s", tglMulai, tglSelesai)
	}

	response.SummaryCards = []models.SummaryCardModel{
		{Label: "TOTAL POTENSI LAHAN", Value: totals.Area, Unit: "HA", Type: "potensi"},
		{Label: "TOTAL LOKASI", Value: float64(totals.Count), Unit: "LOKASI", Type: "lokasi"},
	}

	// =============================
	// SUMMARY
	// =============================

	potensi := getSummaryData(dbPotensi, "Total Potensi Lahan", "#0D47A1", []string{"1", "2", "3", "4"})

	tanam := getTransactionSummary(
		baseQuery.Session(&gorm.Session{}),
		"Total Lahan Tanam",
		"#2E7D32",
		"tanam",
		"luastanam",
		"tgltanam",
		tglMulai,
		tglSelesai,
	)

	panen := getTransactionSummary(
		baseQuery.Session(&gorm.Session{}),
		"Total Lahan Panen",
		"#C62828",
		"panen",
		"luaspanen",
		"tglpanen",
		tglMulai,
		tglSelesai,
	)

	response.LahanSummary = []models.LahanSummaryModel{
		potensi,
		tanam,
		panen,
	}

	// =============================
	// CHART DATA
	// =============================

	response.HarvestSummary = getHarvestGrowthSummary(
		baseQuery.Session(&gorm.Session{}),
		idKomoditi,
		jenisKomoditi,
	)

	response.QuarterlyData = getQuarterlySummary(
		baseQuery.Session(&gorm.Session{}),
		idKomoditi,
		resor,
		sektor,
		user.Role,
		user.IDTugas,
	)

	// =============================
	// PANEN STATUS
	// =============================

	response.PanenStatus = getPanenStatusSummary(baseQuery.Session(&gorm.Session{}))

	// =============================
	// RESAPAN
	// =============================

	response.ResapanYearly = GetResapanSummary(baseQuery.Session(&gorm.Session{}))

	// =============================
	// MAP
	// =============================

	response.MapPotensi = getMapPotensiSummary(
		baseQuery.Session(&gorm.Session{}),
	)

	// =============================
	// DISTRIBUSI WILAYAH
	// =============================

	distIdTingkat := ""
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		distIdTingkat = user.IDTugas
	} else if resor != "" {
		rName := strings.ReplaceAll(strings.ToUpper(resor), "POLRES ", "")
		var code string
		initializers.DB.Table("wilayah").
			Select("id_wilayah").
			Where("UPPER(nama_wilayah) LIKE ?", "%"+rName+"%").
			Where("CHAR_LENGTH(id_wilayah) = 5").
			Limit(1).
			Scan(&code)
		distIdTingkat = code
	}

	response.WilayahDistribution = getWilayahDistribution(
		initializers.DB,
		distIdTingkat,
		idKomoditi,
		jenisKomoditi,
	)

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   response,
	})
}

func getLahanLabel(id int) string {
	switch id {
	case 1:
		return "PERHUTANAN SOSIAL"
	case 2:
		return "POKTAN BINAAN POLRI"
	case 3:
		return "LBS"
	case 4:
		return "PESANTREN"
	case 5:
		return "MILIK POLRI"
	case 6:
		return "MASYARAKAT BINAAN POLRI"
	case 7:
		return "TUMPANG SARI"
	case 8:
		return "PERHUTANI/INHUTANI"
	default:
		return "LAINNYA"
	}
}

// Agregasi untuk Tabel Master (Lahan)
func getSummaryData(db *gorm.DB, title string, color string, statusFilter []string) models.LahanSummaryModel {

	type result struct {
		IDJenis int     `gorm:"column:id_jenis_lahan"`
		Area    float64 `gorm:"column:area"`
		Count   int64   `gorm:"column:count"`
	}

	var results []result

	err := db.
		Where("lahan.deletestatus = ?", "2").
		Where("lahan.status_lahan IN ?", statusFilter).
		Select(`
        lahan.id_jenis_lahan,
        COALESCE(SUM(lahan.luas_lahan),0) as area,
        COUNT(lahan.id_lahan) as count
    `).
		Group("lahan.id_jenis_lahan").
		Scan(&results).Error

	if err != nil {
		return models.LahanSummaryModel{
			Title:           title,
			BackgroundColor: color,
			TotalValue:      0,
			Items:           []models.LahanDetailItem{},
		}
	}

	var items []models.LahanDetailItem
	var totalArea float64

	for _, r := range results {

		items = append(items, models.LahanDetailItem{
			Label: getLahanLabel(r.IDJenis),
			Value: r.Area,
			Count: r.Count,
		})

		totalArea += r.Area
	}

	return models.LahanSummaryModel{
		Title:           title,
		BackgroundColor: color,
		TotalValue:      totalArea,
		Items:           items,
	}
}

// Agregasi untuk Tabel Transaksi (Tanam & Panen)
func getTransactionSummary(
	db *gorm.DB,
	title string,
	color string,
	table string,
	col string,
	dateCol string,
	tglMulai string,
	tglSelesai string,
) models.LahanSummaryModel {

	type result struct {
		IDJenis int     `gorm:"column:id_jenis_lahan"`
		Area    float64 `gorm:"column:area"`
		Count   int64   `gorm:"column:count"`
	}

	var results []result
	var query *gorm.DB

	if table == "tanam" {

		query = db.Table("tanam").
			Select(`
				lahan.id_jenis_lahan,
				COALESCE(SUM(tanam.luas_tanam),0) as area,
				COUNT(lahan.id_lahan) as count
			`).
			Joins("JOIN lahan ON lahan.id_lahan = tanam.id_lahan").
			Where("tanam.deletestatus = ?", "2")

		if tglMulai != "" && tglSelesai != "" {
			query = query.Where("tanam."+dateCol+" BETWEEN ? AND ?", tglMulai, tglSelesai)
		}

	} else if table == "panen" {

		query = db.Table("panen").
			Select(`
				lahan.id_jenis_lahan,
				COALESCE(SUM(panen.luas_panen),0) as area,
				COUNT(lahan.id_lahan) as count
			`).
			Joins("JOIN tanam ON tanam.id_tanam = panen.id_tanam").
			Joins("JOIN lahan ON lahan.id_lahan = tanam.id_lahan").
			Where("panen.deletestatus = ?", "2")

		if tglMulai != "" && tglSelesai != "" {
			query = query.Where("panen."+dateCol+" BETWEEN ? AND ?", tglMulai, tglSelesai)
		}
	}

	err := query.
		Group("lahan.id_jenis_lahan").
		Scan(&results).Error

	if err != nil {
		return models.LahanSummaryModel{
			Title:           title,
			BackgroundColor: color,
			TotalValue:      0,
			Items:           []models.LahanDetailItem{},
		}
	}

	var items []models.LahanDetailItem
	var totalArea float64

	for _, r := range results {

		items = append(items, models.LahanDetailItem{
			Label: getLahanLabel(r.IDJenis),
			Value: r.Area,
			Count: r.Count,
		})

		totalArea += r.Area
	}

	return models.LahanSummaryModel{
		Title:           title,
		BackgroundColor: color,
		TotalValue:      totalArea,
		Items:           items,
	}
}

// Helper untuk Agregasi Grafik Pertumbuhan (Trend Panen Bulanan)
func getHarvestGrowthSummary(db *gorm.DB, idKomoditi string, jenisKomoditi string) models.HarvestSummaryModel {

	currentYear := time.Now().Year()

	type komRow struct {
		ID   string `gorm:"column:id_komoditi"`
		Nama string `gorm:"column:nama_komoditi"`
	}

	var koms []komRow

	komQ := initializers.DB.Table("komoditi").
		Select("id_komoditi, nama_komoditi").
		Where("deletestatus = ?", "2")

	if jenisKomoditi != "" {
		komQ = komQ.Where("UPPER(jenis_komoditi) = ?", strings.ToUpper(jenisKomoditi))
	}

	if idKomoditi != "" {
		komQ = komQ.Where("id_komoditi = ?", idKomoditi)
	}

	komQ.Order("id_komoditi ASC").Scan(&koms)

	colors := []string{
		"#34D399",
		"#FBBF24",
		"#60A5FA",
		"#F87171",
		"#A78BFA",
	}

	catMap := map[string]*models.HarvestCategory{}
	colorIdx := 0

	for _, k := range koms {

		points := make([]models.HarvestPoint, 12)

		for i := 0; i < 12; i++ {
			points[i] = models.HarvestPoint{
				Month: i + 1,
				Year:  currentYear,
				Value: 0,
			}
		}

		catMap[k.ID] = &models.HarvestCategory{
			ID:         k.ID,
			Label:      k.Nama,
			Color:      colors[colorIdx%len(colors)],
			DataPoints: points,
		}

		colorIdx++
	}

	type aggRow struct {
		Month        int     `gorm:"column:month"`
		Year         int     `gorm:"column:year"`
		IDKomoditi   string  `gorm:"column:id_komoditi"`
		NamaKomoditi string  `gorm:"column:nama_komoditi"`
		TotalLuas    float64 `gorm:"column:total_luas"`
	}

	var aggs []aggRow

	q := db.Table("panen").
		Select(`
			MONTH(panen.tgl_panen) as month,
			YEAR(panen.tgl_panen) as year,
			komoditi.id_komoditi as id_komoditi,
			komoditi.nama_komoditi as nama_komoditi,
			SUM(panen.total_panen) as total_luas
		`).
		Joins("JOIN tanam ON tanam.id_tanam = panen.id_tanam").
		Joins("JOIN lahan ON lahan.id_lahan = tanam.id_lahan").
		Joins("JOIN komoditi ON komoditi.id_komoditi = lahan.id_komoditi").
		Where("panen.deletestatus = ?", "2").
		Where("YEAR(panen.tgl_panen) = ?", currentYear)

	if idKomoditi != "" {
		q = q.Where("komoditi.id_komoditi = ?", idKomoditi)
	}

	if jenisKomoditi != "" {
		q = q.Where("UPPER(komoditi.jenis_komoditi) = ?", strings.ToUpper(jenisKomoditi))
	}

	q.Group("komoditi.id_komoditi, komoditi.nama_komoditi, year, month").
		Order("year ASC, month ASC").
		Scan(&aggs)

	var totalOverall float64

	for _, a := range aggs {

		cat, ok := catMap[a.IDKomoditi]

		if !ok {

			points := make([]models.HarvestPoint, 12)

			for i := 0; i < 12; i++ {
				points[i] = models.HarvestPoint{
					Month: i + 1,
					Year:  currentYear,
					Value: 0,
				}
			}

			label := a.NamaKomoditi
			if label == "" {
				label = a.IDKomoditi
			}

			cat = &models.HarvestCategory{
				ID:         a.IDKomoditi,
				Label:      label,
				Color:      colors[colorIdx%len(colors)],
				DataPoints: points,
			}

			catMap[a.IDKomoditi] = cat
			colorIdx++
		}

		if a.Month >= 1 && a.Month <= 12 {
			cat.DataPoints[a.Month-1].Value = a.TotalLuas
		}

		totalOverall += a.TotalLuas
	}

	categories := make([]models.HarvestCategory, 0, len(catMap))

	for _, c := range catMap {
		categories = append(categories, *c)
	}

	return models.HarvestSummaryModel{
		TotalPanen: totalOverall,
		Unit:       "HA",
		Categories: categories,
	}
}

// Helper untuk Agregasi Kwartal (Q1 - Q4)
func getQuarterlySummary(
	db *gorm.DB, 
	idKomoditi string, 
	resor string, 
	sektor string, 
	userRole string, 
	userIDTugas string,
) []models.QuarterlyItemModel {

	currentYear := time.Now().Year()

	type row struct {
		Quarter int
		Label   string
		Total   float64
	}

	var rows []row

	var tanamFilters []string
	var tanamArgs []interface{}
	tanamFilters = append(tanamFilters, "t.deletestatus = '2'")
	tanamFilters = append(tanamFilters, "YEAR(t.tgl_tanam) = ?")
	tanamArgs = append(tanamArgs, currentYear)

	if idKomoditi != "" {
		tanamFilters = append(tanamFilters, "l.id_komoditi = ?")
		tanamArgs = append(tanamArgs, idKomoditi)
	}

	var tanamJoins string
	if userRole != "admin" && userRole != "1" && userRole != "Admin" && userIDTugas != "" {
		tanamFilters = append(tanamFilters, "l.id_tingkat LIKE ?")
		tanamArgs = append(tanamArgs, userIDTugas+"%")
	} else {
		if sektor != "" {
			tanamJoins = " LEFT JOIN wilayah w_kec ON w_kec.id_wilayah = SUBSTR(l.id_wilayah, 1, 8) "
			tanamFilters = append(tanamFilters, "UPPER(w_kec.nama_wilayah) LIKE ?")
			sName := strings.ReplaceAll(strings.ToUpper(sektor), "POLSEK ", "")
			tanamArgs = append(tanamArgs, "%"+sName+"%")
		} else if resor != "" {
			tanamJoins = " LEFT JOIN wilayah w_kab ON w_kab.id_wilayah = SUBSTR(l.id_wilayah, 1, 5) "
			tanamFilters = append(tanamFilters, "UPPER(w_kab.nama_wilayah) LIKE ?")
			rName := strings.ReplaceAll(strings.ToUpper(resor), "POLRES ", "")
			tanamArgs = append(tanamArgs, "%"+rName+"%")
		}
	}

	var panenFilters []string
	var panenArgs []interface{}
	panenFilters = append(panenFilters, "p.deletestatus = '2'")
	panenFilters = append(panenFilters, "YEAR(p.tgl_panen) = ?")
	panenArgs = append(panenArgs, currentYear)

	if idKomoditi != "" {
		panenFilters = append(panenFilters, "l.id_komoditi = ?")
		panenArgs = append(panenArgs, idKomoditi)
	}

	var panenJoins string
	if userRole != "admin" && userRole != "1" && userRole != "Admin" && userIDTugas != "" {
		panenFilters = append(panenFilters, "l.id_tingkat LIKE ?")
		panenArgs = append(panenArgs, userIDTugas+"%")
	} else {
		if sektor != "" {
			panenJoins = " LEFT JOIN wilayah w_kec ON w_kec.id_wilayah = SUBSTR(l.id_wilayah, 1, 8) "
			panenFilters = append(panenFilters, "UPPER(w_kec.nama_wilayah) LIKE ?")
			sName := strings.ReplaceAll(strings.ToUpper(sektor), "POLSEK ", "")
			panenArgs = append(panenArgs, "%"+sName+"%")
		} else if resor != "" {
			panenJoins = " LEFT JOIN wilayah w_kab ON w_kab.id_wilayah = SUBSTR(l.id_wilayah, 1, 5) "
			panenFilters = append(panenFilters, "UPPER(w_kab.nama_wilayah) LIKE ?")
			rName := strings.ReplaceAll(strings.ToUpper(resor), "POLRES ", "")
			panenArgs = append(panenArgs, "%"+rName+"%")
		}
	}

	query := fmt.Sprintf(`
	SELECT 
		QUARTER(t.tgl_tanam) quarter,
		'Lahan Tanam' label,
		SUM(t.luas_tanam) total
	FROM tanam t
	JOIN lahan l ON l.id_lahan = t.id_lahan
	%s
	WHERE %s
	GROUP BY QUARTER(t.tgl_tanam)

	UNION ALL

	SELECT 
		QUARTER(p.tgl_panen) quarter,
		'Lahan Panen' label,
		SUM(p.luas_panen) total
	FROM panen p
	JOIN tanam t ON t.id_tanam = p.id_tanam
	JOIN lahan l ON l.id_lahan = t.id_lahan
	%s
	WHERE %s
	GROUP BY QUARTER(p.tgl_panen)
	`, tanamJoins, strings.Join(tanamFilters, " AND "), panenJoins, strings.Join(panenFilters, " AND "))

	var args []interface{}
	args = append(args, tanamArgs...)
	args = append(args, panenArgs...)

	db.Raw(query, args...).Scan(&rows)

	tanam := map[int]float64{}
	panen := map[int]float64{}

	for _, r := range rows {

		switch r.Label {

		case "Lahan Tanam":
			tanam[r.Quarter] += r.Total

		case "Lahan Panen":
			panen[r.Quarter] += r.Total
		}
	}

	quarters := []string{"KW1", "KW2", "KW3", "KW4"}

	var result []models.QuarterlyItemModel

	for i := 1; i <= 4; i++ {

		result = append(result, models.QuarterlyItemModel{
			Label:  "Lahan Tanam",
			Value:  tanam[i],
			Unit:   "HA",
			Period: quarters[i-1],
		})
	}

	for i := 1; i <= 4; i++ {

		result = append(result, models.QuarterlyItemModel{
			Label:  "Lahan Panen",
			Value:  panen[i],
			Unit:   "HA",
			Period: quarters[i-1],
		})
	}

	return result
}

// resapan
type resapanResult struct {
	Bulog     float64 `gorm:"column:bulog"`
	Pakan     float64 `gorm:"column:pakan"`
	Tengkulak float64 `gorm:"column:tengkulak"`
	Konsumsi  float64 `gorm:"column:konsumsi"`
}

func GetResapanSummary(db *gorm.DB) models.ResapanModel {

	currentYear := time.Now().Year()

	var result resapanResult

	db.Table("distribusi").
		Select(`
			SUM(CASE WHEN distribusi.distribusi_ke = 1 THEN distribusi.total_distribusi ELSE 0 END) AS bulog,
			SUM(CASE WHEN distribusi.distribusi_ke = 2 THEN distribusi.total_distribusi ELSE 0 END) AS pakan,
			SUM(CASE WHEN distribusi.distribusi_ke = 3 THEN distribusi.total_distribusi ELSE 0 END) AS tengkulak,
			SUM(CASE WHEN distribusi.distribusi_ke = 4 THEN distribusi.total_distribusi ELSE 0 END) AS konsumsi
		`).
		Joins("JOIN lahan ON lahan.id_lahan = distribusi.id_lahan").
		Where("YEAR(distribusi.tgl_distribusi) = ?", currentYear).
		Where("distribusi.deletestatus = ?", "2").
		Scan(&result)

	items := []models.ResapanItem{
		{"Bulog", result.Bulog},
		{"Pakan", result.Pakan},
		{"Tengkulak", result.Tengkulak},
		{"Konsumsi Sendiri", result.Konsumsi},
	}

	total := result.Bulog + result.Pakan + result.Tengkulak + result.Konsumsi

	return models.ResapanModel{
		Year:  fmt.Sprintf("%d", currentYear),
		Total: total,
		Items: items,
	}
}

// ==============================
// FILTER ENDPOINTS
// ==============================

func GetJenisKomoditiFilter(c *gin.Context) {
	var out []string
	err := initializers.DB.
		Table("komoditi").
		Select("DISTINCT jenis_komoditi").
		Where("deletestatus = ? AND jenis_komoditi IS NOT NULL AND jenis_komoditi <> ''", "2").
		Order("jenis_komoditi ASC").
		Pluck("jenis_komoditi", &out).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": out})
}

func GetKomoditiByJenisFilter(c *gin.Context) {
	jenisKomoditi := c.Query("jenis_komoditi")

	q := initializers.DB.Table("komoditi").
		Select("id_komoditi as id, nama_komoditi as label").
		Where("deletestatus = ?", "2")

	if jenisKomoditi != "" {
		q = q.Where("UPPER(jenis_komoditi) = ?", strings.ToUpper(jenisKomoditi))
	}

	var out []struct {
		ID    string `json:"id"`
		Label string `json:"label"`
	}

	if err := q.Order("nama_komoditi ASC").Scan(&out).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": out})
}

// panen status
func getPanenStatusSummary(db *gorm.DB) []models.SummaryCardModel {

	currentYear := time.Now().Year()

	type row struct {
		Status int
		Total  float64
	}

	var rows []row

	db.Table("panen").
		Select("panen.status_panen as status, SUM(panen.luas_panen) as total").
		Joins("JOIN tanam ON tanam.id_tanam = panen.id_tanam").
		Joins("JOIN lahan ON lahan.id_lahan = tanam.id_lahan").
		Where("panen.deletestatus = ?", "2").
		Where("YEAR(panen.tgl_panen) = ?", currentYear).
		Group("panen.status_panen").
		Scan(&rows)

	result := map[int]float64{
		1: 0,
		2: 0,
		3: 0,
		4: 0,
	}

	for _, r := range rows {
		result[r.Status] = r.Total
	}

	return []models.SummaryCardModel{
		{
			Label: "TOTAL PANEN NORMAL TAHUN " + fmt.Sprint(currentYear),
			Value: result[1],
			Unit:  "HA",
		},
		{
			Label: "TOTAL GAGAL PANEN TAHUN " + fmt.Sprint(currentYear),
			Value: result[2],
			Unit:  "HA",
		},
		{
			Label: "TOTAL PANEN DINI TAHUN " + fmt.Sprint(currentYear),
			Value: result[3],
			Unit:  "HA",
		},
		{
			Label: "TOTAL PANEN TEBASAN TAHUN " + fmt.Sprint(currentYear),
			Value: result[4],
			Unit:  "HA",
		},
	}
}

// MAP POTENSI ENDPOINT (optional terpisah dari /dashboard)

func GetDashboardMapPotensi(c *gin.Context) {

	resor := c.Query("resor")
	sektor := c.Query("sektor")
	idJenis := c.Query("id_jenis_lahan")
	idKomoditi := c.Query("id_komoditi")
	jenisKomoditi := c.Query("jenis_komoditi")

	// Get user from context
	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	baseQuery := initializers.DB.Model(&models.Lahan{})

	// Enforce role-based scoping
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		baseQuery = baseQuery.Where("lahan.id_tingkat LIKE ?", user.IDTugas+"%")
	}

	baseQuery = applyWilayahFilter(baseQuery, resor, sektor)
	baseQuery = applyJenisLahanFilter(baseQuery, idJenis)
	baseQuery = applyKomoditiFilter(baseQuery, idKomoditi, jenisKomoditi)

	data := getMapPotensiSummary(baseQuery.Session(&gorm.Session{}))

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   data,
	})
}

func applyWilayahFilter(db *gorm.DB, resor string, sektor string) *gorm.DB {

	if sektor != "" {

		sName := strings.ReplaceAll(strings.ToUpper(sektor), "POLSEK ", "")

		var kode string

		initializers.DB.
			Table("wilayah").
			Select("id_wilayah").
			Where("UPPER(nama_wilayah) LIKE ?", "%"+sName+"%").
			Where("CHAR_LENGTH(id_wilayah) = 8").
			Limit(1).
			Scan(&kode)

		if kode != "" {
			db = db.Where("lahan.id_wilayah LIKE ?", kode+"%")
		}

	} else if resor != "" {

		rName := strings.ReplaceAll(strings.ToUpper(resor), "POLRES ", "")

		var kode string

		initializers.DB.
			Table("wilayah").
			Select("id_wilayah").
			Where("UPPER(nama_wilayah) LIKE ?", "%"+rName+"%").
			Where("CHAR_LENGTH(id_wilayah) = 5").
			Limit(1).
			Scan(&kode)

		if kode != "" {
			db = db.Where("lahan.id_wilayah LIKE ?", kode+"%")
		}
	}

	return db
}
func applyKomoditiFilter(db *gorm.DB, idKomoditi string, jenisKomoditi string) *gorm.DB {

	if idKomoditi != "" {
		db = db.Where("lahan.id_komoditi = ?", idKomoditi)
	}

	if jenisKomoditi != "" {

		db = db.Joins(`
			JOIN komoditi k 
			ON k.id_komoditi = lahan.id_komoditi
		`).
			Where("k.deletestatus = '2'").
			Where("UPPER(k.jenis_komoditi) = ?", strings.ToUpper(jenisKomoditi))
	}

	return db
}
func applyJenisLahanFilter(db *gorm.DB, idJenis string) *gorm.DB {

	if idJenis != "" {
		db = db.Where("lahan.id_jenis_lahan = ?", idJenis)
	}

	return db
}

func getMapPotensiSummary(db *gorm.DB) models.MapPotensiModel {
	// ✅ sesuai DB kamu
	const LAT_COL = "lahan.latitude"
	const LNG_COL = "lahan.longitude"

	// ✅ jangan kebesaran biar tidak overload (mobile map juga berat render 5000 marker)
	const DEFAULT_LIMIT = 2000
	const JATIM_MIN_LAT = -8.9
	const JATIM_MAX_LAT = -6.3
	const JATIM_MIN_LNG = 111.0
	const JATIM_MAX_LNG = 114.9

	type row struct {
		IDLahan     string  `gorm:"column:id_lahan"`
		Lat         float64 `gorm:"column:lat"`
		Lng         float64 `gorm:"column:lng"`
		LuasLahan   float64 `gorm:"column:luas_lahan"`
		StatusLahan string  `gorm:"column:status_lahan"`
		IDJenis     int     `gorm:"column:id_jenis_lahan"`

		IDKomoditi *string `gorm:"column:id_komoditi"`
		NamaKom    *string `gorm:"column:nama_komoditi"`
		JenisKom   *string `gorm:"column:jenis_komoditi"`
		KodeWil    *string `gorm:"column:id_wilayah"`
		NamaWil    *string `gorm:"column:nama_wilayah"`
	}

	var rows []row

	q := db.Session(&gorm.Session{}).
		Select(`
			lahan.id_lahan as id_lahan,
			`+LAT_COL+` as lat,
			`+LNG_COL+` as lng,
			COALESCE(lahan.luas_lahan, 0) as luas_lahan,
			lahan.status_lahan as status_lahan,
			lahan.id_jenis_lahan as id_jenis_lahan,
			komoditi.id_komoditi as id_komoditi,
			komoditi.nama_komoditi as nama_komoditi,
			komoditi.jenis_komoditi as jenis_komoditi,
			lahan.id_wilayah as id_wilayah,
			w.nama_wilayah as nama_wilayah
		`).
		Joins(`LEFT JOIN komoditi ON komoditi.id_komoditi = lahan.id_komoditi AND komoditi.deletestatus = '2'`).
		Joins(`LEFT JOIN wilayah w ON w.id_wilayah = lahan.id_wilayah`).
		Where(`lahan.status_lahan IN ('1','2','3','4')`).
		Where(LAT_COL+" IS NOT NULL AND "+LNG_COL+" IS NOT NULL").
		Where(LAT_COL+" <> 0 AND "+LNG_COL+" <> 0").
		Where(LAT_COL+" BETWEEN -90 AND 90").
		Where(LNG_COL+" BETWEEN -180 AND 180").
		// ✅ batasi area Jatim biar tidak kebanyakan data (hapus kalau tidak mau)
		Where(LAT_COL+" BETWEEN ? AND ?", JATIM_MIN_LAT, JATIM_MAX_LAT).
		Where(LNG_COL+" BETWEEN ? AND ?", JATIM_MIN_LNG, JATIM_MAX_LNG).
		Order("lahan.id_lahan DESC").
		Limit(DEFAULT_LIMIT)

	if err := q.Scan(&rows).Error; err != nil {
		return models.MapPotensiModel{TotalPoints: 0, Points: []models.MapPotensiItem{}}
	}

	out := make([]models.MapPotensiItem, 0, len(rows))
	for _, r := range rows {
		out = append(out, models.MapPotensiItem{
			IDLahan:     r.IDLahan,
			Lat:         r.Lat,
			Lng:         r.Lng,
			LuasLahan:   r.LuasLahan,
			StatusLahan: r.StatusLahan,
			JenisLahan:  getLahanLabel(r.IDJenis),

			IDKomoditi:    r.IDKomoditi,
			NamaKomoditi:  r.NamaKom,
			JenisKomoditi: r.JenisKom,

			KodeWilayah: r.KodeWil,
			NamaWilayah: r.NamaWil,
		})
	}

	return models.MapPotensiModel{
		TotalPoints: int64(len(out)),
		Points:      out,
	}
}
type WilayahDistributionModel struct {
	Label string  `json:"label"`
	Value float64 `json:"value"`
}

func getWilayahDistribution(db *gorm.DB, idTingkat string, idKomoditi string, jenisKomoditi string) []models.WilayahDistributionModel {

	type row struct {
		Potensi int64 `gorm:"column:polsek_potensi"`
		Tanpa   int64 `gorm:"column:polsek_tanpa_potensi"`
		Total   int64 `gorm:"column:total_polsek"`
	}

	var r row

	query := db.Table("tingkat t").
		Select(`
			COUNT(DISTINCT CASE WHEN l.id_lahan IS NOT NULL THEN t.id_tingkat END) AS polsek_potensi,
			COUNT(DISTINCT CASE WHEN l.id_lahan IS NULL THEN t.id_tingkat END) AS polsek_tanpa_potensi,
			COUNT(DISTINCT t.id_tingkat) AS total_polsek
		`).
		Joins(`
			LEFT JOIN lahan l
			ON l.id_tingkat = t.id_tingkat
			AND l.deletestatus = '2'
		`).
		Where("CHAR_LENGTH(t.id_tingkat) = 8")

	if idTingkat != "" {
		query = query.Where("t.id_tingkat LIKE ?", idTingkat+"%")
	}

	if idKomoditi != "" {
		query = query.Where("l.id_komoditi = ?", idKomoditi)
	}

	if jenisKomoditi != "" {
		query = query.
			Joins("JOIN komoditi k ON k.id_komoditi = l.id_komoditi").
			Where("k.deletestatus = '2'").
			Where("UPPER(k.jenis_komoditi) = ?", strings.ToUpper(jenisKomoditi))
	}

	query.Scan(&r)

	results := []models.WilayahDistributionModel{
		{
			Label: "Polsek dengan Potensi Lahan",
			Value: float64(r.Potensi),
		},
		{
			Label: "Polsek tanpa Potensi Lahan",
			Value: float64(r.Tanpa),
		},
	}

	return results
}
func GetWilayahDistribution(c *gin.Context) {

	resor := c.Query("resor")
	sektor := c.Query("sektor")
	idKomoditi := c.Query("id_komoditi")
	jenisKomoditi := c.Query("jenis_komoditi")

	// Get user from context
	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	distIdTingkat := ""
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		distIdTingkat = user.IDTugas
	} else if sektor != "" {
		sName := strings.ReplaceAll(strings.ToUpper(sektor), "POLSEK ", "")
		var code string
		initializers.DB.Table("wilayah").
			Select("id_wilayah").
			Where("UPPER(nama_wilayah) LIKE ?", "%"+sName+"%").
			Where("CHAR_LENGTH(id_wilayah) = 8").
			Limit(1).
			Row().
			Scan(&code)
		distIdTingkat = code
	} else if resor != "" {
		rName := strings.ReplaceAll(strings.ToUpper(resor), "POLRES ", "")
		var code string
		initializers.DB.Table("wilayah").
			Select("id_wilayah").
			Where("UPPER(nama_wilayah) LIKE ?", "%"+rName+"%").
			Where("CHAR_LENGTH(id_wilayah) = 5").
			Limit(1).
			Row().
			Scan(&code)
		distIdTingkat = code
	}

	data := getWilayahDistribution(
		initializers.DB.Session(&gorm.Session{}),
		distIdTingkat,
		idKomoditi,
		jenisKomoditi,
	)

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   data,
	})
}
