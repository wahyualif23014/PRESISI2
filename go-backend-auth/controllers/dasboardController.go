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

	baseQuery := initializers.DB.Model(&models.Lahan{})

	// Filter Wilayah
	if sektor != "" {
		sName := strings.ReplaceAll(strings.ToUpper(sektor), "POLSEK ", "")
		baseQuery = baseQuery.Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = SUBSTR(lahan.idwilayah, 1, 8)").
			Where("UPPER(w_kec.nama) LIKE ?", "%"+sName+"%")
	} else if resor != "" {
		rName := strings.ReplaceAll(strings.ToUpper(resor), "POLRES ", "")
		baseQuery = baseQuery.Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah, 1, 5)").
			Where("UPPER(w_kab.nama) LIKE ?", "%"+rName+"%")
	}

	// Filter Jenis Lahan
	if idJenis != "" {
		baseQuery = baseQuery.Where("lahan.idjenislahan = ?", idJenis)
	}

	// Filter Jenis Komoditi (subquery IN agar tidak butuh join tambahan)
	if jenisKomoditi != "" {
		sub := initializers.DB.
			Table("komoditi").
			Select("idkomoditi").
			Where("deletestatus = ? AND UPPER(jeniskomoditi) = ?", "2", strings.ToUpper(jenisKomoditi))

		baseQuery = baseQuery.Where("lahan.idkomoditi IN (?)", sub)
	}

	// Filter Komoditi spesifik
	if idKomoditi != "" {
		baseQuery = baseQuery.Where("lahan.idkomoditi = ?", idKomoditi)
	}

	// Totals (Potensi)
	// Totals (Potensi)
	var totals struct {
		Area  float64
		Count int64
	}

	dbPotensi := baseQuery.Session(&gorm.Session{})

	err := initializers.DB.
		Model(&models.Lahan{}).
		Where("deletestatus = ?", "2").
		Where("statuslahan IN ?", []string{"1", "2", "3", "4"}).
		Select(`
		COALESCE(SUM(luaslahan),0) as area,
		COUNT(idlahan) as count
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

	// Summary
	potensi := getSummaryData(dbPotensi, "Total Potensi Lahan", "#0D47A1", []string{"1", "2", "3", "4"})
	tanam := getTransactionSummary(baseQuery.Session(&gorm.Session{}), "Total Lahan Tanam", "#2E7D32", "tanam", "luastanam", "tgltanam", tglMulai, tglSelesai)
	panen := getTransactionSummary(baseQuery.Session(&gorm.Session{}), "Total Lahan Panen", "#C62828", "panen", "luaspanen", "tglpanen", tglMulai, tglSelesai)

	response.LahanSummary = []models.LahanSummaryModel{potensi, tanam, panen}

	// Growth chart (trend panen)
	response.HarvestSummary = getHarvestGrowthSummary(baseQuery.Session(&gorm.Session{}), idKomoditi, jenisKomoditi)

	// Quarterly chart
	response.QuarterlyData = getQuarterlySummary(baseQuery.Session(&gorm.Session{}), idKomoditi)

	response.PanenStatus = getPanenStatusSummary(baseQuery.Session(&gorm.Session{}))

	// Resapan
	response.ResapanYearly = getResapanSummary(baseQuery.Session(&gorm.Session{}), idKomoditi)

	// ✅ Peta penyebaran potensi lahan
	response.MapPotensi = getMapPotensiSummary(baseQuery.Session(&gorm.Session{}))

	// Distribusi Wilayah (tetap)
	// Distribusi Wilayah Baru
	response.WilayahDistribution = getWilayahDistribution(
		baseQuery.Session(&gorm.Session{}),
		"", // idTingkat jika ada filter
		idKomoditi,
		jenisKomoditi,
	)

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": response})
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
		IDJenis int     `gorm:"column:idjenislahan"`
		Area    float64 `gorm:"column:area"`
		Count   int64   `gorm:"column:count"`
	}

	var results []result

	err := db.
		Where("lahan.deletestatus = ?", "2").
		Where("lahan.statuslahan IN ?", statusFilter).
		Select(`
        lahan.idjenislahan,
        COALESCE(SUM(lahan.luaslahan),0) as area,
        COUNT(lahan.idlahan) as count
    `).
		Group("lahan.idjenislahan").
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
		IDJenis int     `gorm:"column:idjenislahan"`
		Area    float64 `gorm:"column:area"`
		Count   int64   `gorm:"column:count"`
	}

	var results []result
	var query *gorm.DB

	if table == "tanam" {

		query = db.Table("tanam").
			Select(`
				lahan.idjenislahan,
				COALESCE(SUM(tanam.luastanam),0) as area,
				COUNT(lahan.idlahan) as count
			`).
			Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
			Where("tanam.deletestatus = ?", "2")

		if tglMulai != "" && tglSelesai != "" {
			query = query.Where("tanam."+dateCol+" BETWEEN ? AND ?", tglMulai, tglSelesai)
		}

	} else if table == "panen" {

		query = db.Table("panen").
			Select(`
				lahan.idjenislahan,
				COALESCE(SUM(panen.luaspanen),0) as area,
				COUNT(lahan.idlahan) as count
			`).
			Joins("JOIN tanam ON tanam.idtanam = panen.idtanam").
			Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
			Where("panen.deletestatus = ?", "2")

		if tglMulai != "" && tglSelesai != "" {
			query = query.Where("panen."+dateCol+" BETWEEN ? AND ?", tglMulai, tglSelesai)
		}
	}

	err := query.
		Group("lahan.idjenislahan").
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
		ID   string `gorm:"column:idkomoditi"`
		Nama string `gorm:"column:namakomoditi"`
	}

	var koms []komRow

	komQ := initializers.DB.Table("komoditi").
		Select("idkomoditi, namakomoditi").
		Where("deletestatus = ?", "2")

	if jenisKomoditi != "" {
		komQ = komQ.Where("UPPER(jeniskomoditi) = ?", strings.ToUpper(jenisKomoditi))
	}

	if idKomoditi != "" {
		komQ = komQ.Where("idkomoditi = ?", idKomoditi)
	}

	komQ.Order("idkomoditi ASC").Scan(&koms)

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
		IDKomoditi   string  `gorm:"column:idkomoditi"`
		NamaKomoditi string  `gorm:"column:namakomoditi"`
		TotalLuas    float64 `gorm:"column:total_luas"`
	}

	var aggs []aggRow

	q := db.Table("panen").
		Select(`
			MONTH(panen.tglpanen) as month,
			YEAR(panen.tglpanen) as year,
			komoditi.idkomoditi as idkomoditi,
			komoditi.namakomoditi as namakomoditi,
			SUM(panen.luaspanen) as total_luas
		`).
		Joins("JOIN tanam ON tanam.idtanam = panen.idtanam").
		Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
		Joins("JOIN komoditi ON komoditi.idkomoditi = lahan.idkomoditi").
		Where("panen.deletestatus = ?", "2").
		Where("YEAR(panen.tglpanen) = ?", currentYear)

	if idKomoditi != "" {
		q = q.Where("komoditi.idkomoditi = ?", idKomoditi)
	}

	if jenisKomoditi != "" {
		q = q.Where("UPPER(komoditi.jeniskomoditi) = ?", strings.ToUpper(jenisKomoditi))
	}

	q.Group("komoditi.idkomoditi, komoditi.namakomoditi, year, month").
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
func getQuarterlySummary(db *gorm.DB, idKomoditi string) []models.QuarterlyItemModel {

	currentYear := time.Now().Year()

	type row struct {
		Quarter int     `gorm:"column:quarter"`
		Label   string  `gorm:"column:label"`
		Total   float64 `gorm:"column:total"`
	}

	var rows []row

	query := db.Table("(?) as q", db.Raw(`

    SELECT
        QUARTER(t.tgltanam) as quarter,
        'Lahan Tanam' as label,
        SUM(t.luastanam) as total
    FROM tanam t
    JOIN lahan l ON l.idlahan = t.idlahan
    WHERE t.deletestatus='2'
    AND YEAR(t.tgltanam)=?
    GROUP BY QUARTER(t.tgltanam)

    UNION ALL

    SELECT
        QUARTER(p.tglpanen) as quarter,
        'Lahan Panen' as label,
        SUM(p.luaspanen) as total
    FROM panen p
    JOIN tanam t ON t.idtanam = p.idtanam
    JOIN lahan l ON l.idlahan = t.idlahan
    WHERE p.deletestatus='2'
    AND YEAR(p.tglpanen)=?
    GROUP BY QUARTER(p.tglpanen)

`, currentYear, currentYear))

	if idKomoditi != "" {
		query = query.Where("l.idkomoditi = ?", idKomoditi)
	}

	err := query.Scan(&rows).Error
	if err != nil {
		return []models.QuarterlyItemModel{}
	}

	mapTanam := map[int]float64{}
	mapPanen := map[int]float64{}

	for _, r := range rows {

		if r.Label == "Lahan Tanam" {
			mapTanam[r.Quarter] += r.Total
		}

		if r.Label == "Lahan Panen" {
			mapPanen[r.Quarter] += r.Total
		}
	}

	quarterLabels := []string{"KW1", "KW2", "KW3", "KW4"}

	var items []models.QuarterlyItemModel

	for i := 1; i <= 4; i++ {

		items = append(items, models.QuarterlyItemModel{
			Label:  "Lahan Tanam",
			Value:  mapTanam[i],
			Unit:   "HA",
			Period: quarterLabels[i-1],
		})

		items = append(items, models.QuarterlyItemModel{
			Label:  "Lahan Panen",
			Value:  mapPanen[i],
			Unit:   "HA",
			Period: quarterLabels[i-1],
		})
	}

	return items
}

// resapan

func getResapanSummary(db *gorm.DB, idKomoditi string) models.ResapanModel {
	var results []struct {
		IDJenis int     `gorm:"column:idj"`
		Total   float64 `gorm:"column:total"`
	}

	currentYear := time.Now().Year()

	query := db.Table("tanam").
		Select("lahan.idjenislahan as idj, SUM(tanam.luastanam) as total").
		Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
		Where("tanam.deletestatus = ? AND YEAR(tanam.tgltanam) = ?", "2", currentYear)

	if idKomoditi != "" {
		query = query.Where("lahan.idkomoditi = ?", idKomoditi)
	}

	query.Group("idj").Scan(&results)

	var items []models.ResapanItem
	var grandTotal float64

	for _, res := range results {
		items = append(items, models.ResapanItem{
			Label: getLahanLabel(res.IDJenis),
			Value: res.Total,
		})
		grandTotal += res.Total
	}

	return models.ResapanModel{
		Year:  fmt.Sprintf("%d", currentYear),
		Total: grandTotal,
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
		Select("DISTINCT jeniskomoditi").
		Where("deletestatus = ? AND jeniskomoditi IS NOT NULL AND jeniskomoditi <> ''", "2").
		Order("jeniskomoditi ASC").
		Pluck("jeniskomoditi", &out).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": out})
}

func GetKomoditiByJenisFilter(c *gin.Context) {
	jenisKomoditi := c.Query("jenis_komoditi")

	q := initializers.DB.Table("komoditi").
		Select("idkomoditi as id, namakomoditi as label").
		Where("deletestatus = ?", "2")

	if jenisKomoditi != "" {
		q = q.Where("UPPER(jeniskomoditi) = ?", strings.ToUpper(jenisKomoditi))
	}

	var out []struct {
		ID    string `json:"id"`
		Label string `json:"label"`
	}

	if err := q.Order("namakomoditi ASC").Scan(&out).Error; err != nil {
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
		Select("statuspanen as status, SUM(luaspanen) as total").
		Where("deletestatus = ?", "2").
		Where("YEAR(tglpanen) = ?", currentYear).
		Group("statuspanen").
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

	baseQuery := initializers.DB.Model(&models.Lahan{})

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
			Select("kode").
			Where("UPPER(nama) LIKE ?", "%"+sName+"%").
			Where("CHAR_LENGTH(kode) = 8").
			Limit(1).
			Scan(&kode)

		if kode != "" {
			db = db.Where("lahan.idwilayah LIKE ?", kode+"%")
		}

	} else if resor != "" {

		rName := strings.ReplaceAll(strings.ToUpper(resor), "POLRES ", "")

		var kode string

		initializers.DB.
			Table("wilayah").
			Select("kode").
			Where("UPPER(nama) LIKE ?", "%"+rName+"%").
			Where("CHAR_LENGTH(kode) = 5").
			Limit(1).
			Scan(&kode)

		if kode != "" {
			db = db.Where("lahan.idwilayah LIKE ?", kode+"%")
		}
	}

	return db
}
func applyKomoditiFilter(db *gorm.DB, idKomoditi string, jenisKomoditi string) *gorm.DB {

	if idKomoditi != "" {
		db = db.Where("lahan.idkomoditi = ?", idKomoditi)
	}

	if jenisKomoditi != "" {

		db = db.Joins(`
			JOIN komoditi k 
			ON k.idkomoditi = lahan.idkomoditi
		`).
			Where("k.deletestatus = '2'").
			Where("UPPER(k.jeniskomoditi) = ?", strings.ToUpper(jenisKomoditi))
	}

	return db
}
func applyJenisLahanFilter(db *gorm.DB, idJenis string) *gorm.DB {

	if idJenis != "" {
		db = db.Where("lahan.idjenislahan = ?", idJenis)
	}

	return db
}

func getMapPotensiSummary(db *gorm.DB) models.MapPotensiModel {
	// ✅ sesuai DB kamu
	const LAT_COL = "lahan.lat"
	const LNG_COL = "lahan.longi"

	// ✅ jangan kebesaran biar tidak overload (mobile map juga berat render 5000 marker)
	const DEFAULT_LIMIT = 2000
	const JATIM_MIN_LAT = -8.9
	const JATIM_MAX_LAT = -6.3
	const JATIM_MIN_LNG = 111.0
	const JATIM_MAX_LNG = 114.9

	type row struct {
		IDLahan     string  `gorm:"column:idlahan"`
		Lat         float64 `gorm:"column:lat"`
		Lng         float64 `gorm:"column:lng"`
		LuasLahan   float64 `gorm:"column:luaslahan"`
		StatusLahan string  `gorm:"column:statuslahan"`
		IDJenis     int     `gorm:"column:idjenislahan"`

		IDKomoditi *string `gorm:"column:idkomoditi"`
		NamaKom    *string `gorm:"column:namakomoditi"`
		JenisKom   *string `gorm:"column:jeniskomoditi"`
		KodeWil    *string `gorm:"column:idwilayah"`
		NamaWil    *string `gorm:"column:namawilayah"`
	}

	var rows []row

	q := db.Session(&gorm.Session{}).
		Select(`
			lahan.idlahan as idlahan,
			`+LAT_COL+` as lat,
			`+LNG_COL+` as lng,
			COALESCE(lahan.luaslahan, 0) as luaslahan,
			lahan.statuslahan as statuslahan,
			lahan.idjenislahan as idjenislahan,
			komoditi.idkomoditi as idkomoditi,
			komoditi.namakomoditi as namakomoditi,
			komoditi.jeniskomoditi as jeniskomoditi,
			lahan.idwilayah as idwilayah,
			w.nama as namawilayah
		`).
		Joins(`LEFT JOIN komoditi ON komoditi.idkomoditi = lahan.idkomoditi AND komoditi.deletestatus = '2'`).
		Joins(`LEFT JOIN wilayah w ON w.kode = lahan.idwilayah`).
		Where(`lahan.statuslahan IN ('1','2','3','4')`).
		Where(LAT_COL+" IS NOT NULL AND "+LNG_COL+" IS NOT NULL").
		Where(LAT_COL+" <> 0 AND "+LNG_COL+" <> 0").
		Where(LAT_COL+" BETWEEN -90 AND 90").
		Where(LNG_COL+" BETWEEN -180 AND 180").
		// ✅ batasi area Jatim biar tidak kebanyakan data (hapus kalau tidak mau)
		Where(LAT_COL+" BETWEEN ? AND ?", JATIM_MIN_LAT, JATIM_MAX_LAT).
		Where(LNG_COL+" BETWEEN ? AND ?", JATIM_MIN_LNG, JATIM_MAX_LNG).
		Order("lahan.idlahan DESC").
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

func getWilayahDistribution(db *gorm.DB, idTingkat string, idKomoditi string, jenisKomoditi string) []models.WilayahDistributionModel {

	var results []models.WilayahDistributionModel

	subTanam := db.Table("tanam").
		Select("idlahan, SUM(luastanam) as total_tanam").
		Where("deletestatus = ?", "2").
		Group("idlahan")

	query := db.Table("tingkat tw").
		Select(`
			tw.nama as nama_wilayah,
			COUNT(l.idlahan) as total_titik,
			COALESCE(SUM(l.luaslahan),0) as total_luas_potensi,
			COALESCE(SUM(t.total_tanam),0) as total_luas_tanam
		`).
		Joins("LEFT JOIN lahan l ON tw.kode = l.idtingkat AND l.deletestatus='2'").
		Joins("LEFT JOIN (?) t ON l.idlahan = t.idlahan", subTanam)

	if idTingkat != "" {
		query = query.Where("tw.kode LIKE ?", idTingkat+"%")
	}

	if idKomoditi != "" {
		query = query.Where("l.idkomoditi = ?", idKomoditi)
	}

	if jenisKomoditi != "" {
		query = query.
			Joins("JOIN komoditi k ON k.idkomoditi = l.idkomoditi").
			Where("k.deletestatus = '2'").
			Where("UPPER(k.jeniskomoditi) = ?", strings.ToUpper(jenisKomoditi))
	}

	query.Group("tw.kode, tw.nama").
		Order("total_luas_potensi DESC").
		Scan(&results)

	return results
}
func GetWilayahDistribution(c *gin.Context) {

    idTingkat := c.Query("resor")
    idKomoditi := c.Query("id_komoditi")
    jenisKomoditi := c.Query("jenis_komoditi")

    data := getWilayahDistribution(
        initializers.DB.Session(&gorm.Session{}),
        idTingkat,
        idKomoditi,
        jenisKomoditi,
    )

    c.JSON(http.StatusOK, gin.H{
        "status": "success",
        "data": data,
    })
}