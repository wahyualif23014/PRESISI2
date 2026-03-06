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
	var totals struct {
		Area  float64
		Count int64
	}

	dbPotensi := baseQuery.Session(&gorm.Session{})
	dbPotensi.Where("statuslahan IN ('1', '2', '3', '4')").
		Select("COALESCE(SUM(luaslahan), 0) as area, COUNT(DISTINCT idlahan) as count").
		Scan(&totals)

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

	// Resapan
	response.ResapanYearly = getResapanSummary(baseQuery.Session(&gorm.Session{}), idKomoditi)

	// ✅ Peta penyebaran potensi lahan
	response.MapPotensi = getMapPotensiSummary(baseQuery.Session(&gorm.Session{}))

	// Distribusi Wilayah (tetap)
	var admin models.DistributionModel
	admin.Label = "DISTRIBUSI WILAYAH"
	initializers.DB.Table("wilayah").Select("SUM(CASE WHEN CHAR_LENGTH(kode) > 8 THEN 1 ELSE 0 END)").Scan(&admin.Total)
	response.Distribution = append(response.Distribution, admin)

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
	var totalArea float64
	var items []models.LahanDetailItem

	rows, err := db.Where("statuslahan IN ?", statusFilter).
		Select("idjenislahan, COALESCE(SUM(luaslahan), 0) as area, COUNT(DISTINCT idlahan) as count").
		Group("idjenislahan").Rows()
	if err != nil {
		return models.LahanSummaryModel{
			Title:           title,
			BackgroundColor: color,
			TotalValue:      0,
			Items:           []models.LahanDetailItem{},
		}
	}
	defer rows.Close()

	for rows.Next() {
		var id int
		var area float64
		var count int64
		rows.Scan(&id, &area, &count)

		items = append(items, models.LahanDetailItem{
			Label: getLahanLabel(id),
			Value: area,
			Count: count,
		})
		totalArea += area
	}

	return models.LahanSummaryModel{
		Title:           title,
		BackgroundColor: color,
		TotalValue:      totalArea,
		Items:           items,
	}
}

// Agregasi untuk Tabel Transaksi (Tanam & Panen)
func getTransactionSummary(db *gorm.DB, title, color, table, col, dateCol, tglMulai, tglSelesai string) models.LahanSummaryModel {
	var totalArea float64
	var items []models.LahanDetailItem

	query := db.Table(table).
		Select("lahan.idjenislahan, COALESCE(SUM("+table+"."+col+"), 0) as area, COUNT(DISTINCT lahan.idlahan) as count").
		Joins("JOIN lahan ON lahan.idlahan = "+table+".idlahan").
		Where(table+".deletestatus = ?", "2")

	if table == "panen" {
		query = db.Table("panen").
			Select("lahan.idjenislahan, COALESCE(SUM(panen.luaspanen), 0) as area, COUNT(DISTINCT lahan.idlahan) as count").
			Joins("JOIN tanam ON tanam.idtanam = panen.idtanam").
			Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
			Where("panen.deletestatus = ?", "2")
	}

	if tglMulai != "" && tglSelesai != "" {
		query = query.Where(table+"."+dateCol+" BETWEEN ? AND ?", tglMulai, tglSelesai)
	}

	rows, err := query.Group("lahan.idjenislahan").Rows()
	if err != nil {
		return models.LahanSummaryModel{
			Title:           title,
			BackgroundColor: color,
			TotalValue:      0,
			Items:           []models.LahanDetailItem{},
		}
	}
	defer rows.Close()

	for rows.Next() {
		var id int
		var area float64
		var count int64
		rows.Scan(&id, &area, &count)

		items = append(items, models.LahanDetailItem{
			Label: getLahanLabel(id),
			Value: area,
			Count: count,
		})
		totalArea += area
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

	komQ := initializers.DB.Session(&gorm.Session{}).
		Table("komoditi").
		Select("idkomoditi, namakomoditi").
		Where("deletestatus = ?", "2")

	if jenisKomoditi != "" {
		komQ = komQ.Where("UPPER(jeniskomoditi) = ?", strings.ToUpper(jenisKomoditi))
	}
	if idKomoditi != "" {
		komQ = komQ.Where("idkomoditi = ?", idKomoditi)
	}

	komQ.Order("idkomoditi ASC").Scan(&koms)

	colors := []string{"#34D399", "#FBBF24", "#60A5FA", "#F87171", "#A78BFA"}
	catMap := make(map[string]*models.HarvestCategory)
	colorIdx := 0

	for _, k := range koms {
		c := &models.HarvestCategory{
			ID:    k.ID,
			Label: k.Nama,
			Color: colors[colorIdx%len(colors)],
		}
		colorIdx++

		for m := 1; m <= 12; m++ {
			c.DataPoints = append(c.DataPoints, models.HarvestPoint{
				Month: m,
				Year:  currentYear,
				Value: 0,
			})
		}
		catMap[k.ID] = c
	}

	type aggRow struct {
		Month      int     `gorm:"column:m"`
		Year       int     `gorm:"column:y"`
		IDKomoditi string  `gorm:"column:idk"`
		TotalLuas  float64 `gorm:"column:total"`
	}
	var aggs []aggRow

	q := db.Table("panen").
		Select(`
			MONTH(panen.tglpanen) as m,
			YEAR(panen.tglpanen) as y,
			komoditi.idkomoditi as idk,
			SUM(panen.luaspanen) as total
		`).
		Joins("JOIN tanam ON tanam.idtanam = panen.idtanam").
		Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
		Joins("JOIN komoditi ON komoditi.idkomoditi = lahan.idkomoditi").
		Where("panen.deletestatus = ? AND YEAR(panen.tglpanen) = ?", "2", currentYear)

	if idKomoditi != "" {
		q = q.Where("komoditi.idkomoditi = ?", idKomoditi)
	}
	if jenisKomoditi != "" {
		q = q.Where("UPPER(komoditi.jeniskomoditi) = ?", strings.ToUpper(jenisKomoditi))
	}

	q.Group("y, m, idk").Order("y ASC, m ASC").Scan(&aggs)

	var totalOverall float64
	for _, a := range aggs {
		cat, ok := catMap[a.IDKomoditi]
		if !ok {
			cat = &models.HarvestCategory{
				ID:    a.IDKomoditi,
				Label: a.IDKomoditi,
				Color: colors[colorIdx%len(colors)],
			}
			colorIdx++
			for m := 1; m <= 12; m++ {
				cat.DataPoints = append(cat.DataPoints, models.HarvestPoint{
					Month: m,
					Year:  currentYear,
					Value: 0,
				})
			}
			catMap[a.IDKomoditi] = cat
		}

		if a.Month >= 1 && a.Month <= 12 {
			cat.DataPoints[a.Month-1].Value = a.TotalLuas
		}
		totalOverall += a.TotalLuas
	}

	var categories []models.HarvestCategory
	for _, k := range koms {
		if c, ok := catMap[k.ID]; ok {
			categories = append(categories, *c)
		}
	}
	if len(categories) == 0 {
		for _, c := range catMap {
			categories = append(categories, *c)
		}
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
	quarterLabels := []string{"KW1", "KW2", "KW3", "KW4"}
	var items []models.QuarterlyItemModel

	var resTanam []struct {
		Q     int
		Total float64
	}
	qTanam := db.Table("tanam").
		Select("QUARTER(tgltanam) as q, SUM(luastanam) as total").
		Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
		Where("tanam.deletestatus = ? AND YEAR(tgltanam) = ?", "2", currentYear)

	if idKomoditi != "" {
		qTanam = qTanam.Where("lahan.idkomoditi = ?", idKomoditi)
	}

	qTanam.Group("q").Scan(&resTanam)

	var resPanen []struct {
		Q     int
		Total float64
	}
	qPanen := db.Table("panen").
		Select("QUARTER(tglpanen) as q, SUM(luaspanen) as total").
		Joins("JOIN tanam ON tanam.idtanam = panen.idtanam").
		Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
		Where("panen.deletestatus = ? AND YEAR(tglpanen) = ?", "2", currentYear)

	if idKomoditi != "" {
		qPanen = qPanen.Where("lahan.idkomoditi = ?", idKomoditi)
	}

	qPanen.Group("q").Scan(&resPanen)

	mapTanam := map[int]float64{1: 0, 2: 0, 3: 0, 4: 0}
	mapPanen := map[int]float64{1: 0, 2: 0, 3: 0, 4: 0}

	for _, v := range resTanam {
		mapTanam[v.Q] = v.Total
	}
	for _, v := range resPanen {
		mapPanen[v.Q] = v.Total
	}

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

// ==============================
// MAP POTENSI ENDPOINT (optional terpisah dari /dashboard)
// ==============================

func GetDashboardMapPotensi(c *gin.Context) {
	resor := c.Query("resor")
	sektor := c.Query("sektor")
	idJenis := c.Query("id_jenis_lahan")
	idKomoditi := c.Query("id_komoditi")
	jenisKomoditi := c.Query("jenis_komoditi")

	baseQuery := initializers.DB.Model(&models.Lahan{})

	// Filter Wilayah
	if sektor != "" {
		sName := strings.ReplaceAll(strings.ToUpper(sektor), "POLSEK ", "")
		baseQuery = baseQuery.
			Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = SUBSTR(lahan.idwilayah, 1, 8)").
			Where("UPPER(w_kec.nama) LIKE ?", "%"+sName+"%")
	} else if resor != "" {
		rName := strings.ReplaceAll(strings.ToUpper(resor), "POLRES ", "")
		baseQuery = baseQuery.
			Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah, 1, 5)").
			Where("UPPER(w_kab.nama) LIKE ?", "%"+rName+"%")
	}

	// Filter Jenis Lahan
	if idJenis != "" {
		baseQuery = baseQuery.Where("lahan.idjenislahan = ?", idJenis)
	}

	// Filter Jenis Komoditi (subquery IN)
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

	data := getMapPotensiSummary(baseQuery.Session(&gorm.Session{}))

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   data,
	})
}

// ==============================
// HELPER: MAP POTENSI SUMMARY (INI YANG BIKIN ERROR KALAU TIDAK ADA)
// ==============================

func getMapPotensiSummary(db *gorm.DB) models.MapPotensiModel {
	// ✅ sesuai DB kamu
	const LAT_COL = "lahan.lat"
	const LNG_COL = "lahan.longi"

	// ✅ jangan kebesaran biar tidak overload (mobile map juga berat render 5000 marker)
	const DEFAULT_LIMIT = 2000

	// ✅ bounding box Jawa Timur (perkiraan)
	// lat: -8.9 s/d -6.3, lng: 111.0 s/d 114.9
	// Kalau kamu mau nonaktifkan, tinggal hapus 2 Where bbox ini.
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
			` + LAT_COL + ` as lat,
			` + LNG_COL + ` as lng,
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
		Where(LAT_COL + " IS NOT NULL AND " + LNG_COL + " IS NOT NULL").
		Where(LAT_COL + " <> 0 AND " + LNG_COL + " <> 0").
		Where(LAT_COL + " BETWEEN -90 AND 90").
		Where(LNG_COL + " BETWEEN -180 AND 180").
		// ✅ batasi area Jatim biar tidak kebanyakan data (hapus kalau tidak mau)
		Where(LAT_COL + " BETWEEN ? AND ?", JATIM_MIN_LAT, JATIM_MAX_LAT).
		Where(LNG_COL + " BETWEEN ? AND ?", JATIM_MIN_LNG, JATIM_MAX_LNG).
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