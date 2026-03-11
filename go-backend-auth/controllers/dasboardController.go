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

// Helper Sentral Untuk Filter Lahan (Agar Urutan JOIN Aman)
func applyDashboardFilters(query *gorm.DB, c *gin.Context) *gorm.DB {
	resor := c.Query("resor")
	sektor := c.Query("sektor")
	idJenis := c.Query("id_jenis_lahan")
	idKomoditi := c.Query("id_komoditi")
	jenisKomoditi := c.Query("jenis_komoditi")

	// Filter Wilayah
	if sektor != "" {
		sName := strings.ReplaceAll(strings.ToUpper(sektor), "POLSEK ", "")
		query = query.Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = SUBSTR(lahan.idwilayah, 1, 8)").
			Where("UPPER(w_kec.nama) LIKE ?", "%"+sName+"%")
	} else if resor != "" {
		rName := strings.ReplaceAll(strings.ToUpper(resor), "POLRES ", "")
		query = query.Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah, 1, 5)").
			Where("UPPER(w_kab.nama) LIKE ?", "%"+rName+"%")
	}

	// Filter Jenis Lahan
	if idJenis != "" {
		query = query.Where("lahan.idjenislahan = ?", idJenis)
	}

	// Filter Jenis Komoditi
	if jenisKomoditi != "" {
		sub := initializers.DB.Table("komoditi").Select("idkomoditi").
			Where("deletestatus = ? AND UPPER(jeniskomoditi) = ?", "2", strings.ToUpper(jenisKomoditi))
		query = query.Where("lahan.idkomoditi IN (?)", sub)
	}

	// Filter Komoditi spesifik
	if idKomoditi != "" {
		query = query.Where("lahan.idkomoditi = ?", idKomoditi)
	}

	return query
}

func GetDashboardData(c *gin.Context) {
	tglMulai := c.Query("tanggal_mulai")
	tglSelesai := c.Query("tanggal_selesai")

	var response models.DashboardDataResponse
	response.ActiveFilterLabel = "TOTAL POTENSI LAHAN"
	if tglMulai != "" && tglSelesai != "" {
		response.ActiveFilterLabel = fmt.Sprintf("PERIODE %s S/D %s", tglMulai, tglSelesai)
	}

	// 1. Dapatkan Total Potensi
	dbPotensi := initializers.DB.Model(&models.Lahan{})
	dbPotensi = applyDashboardFilters(dbPotensi, c) // Pasang filter di sini

	var totals struct {
		Area  float64
		Count int64
	}
	dbPotensi.Where("statuslahan IN ('1', '2', '3', '4')").
		Select("COALESCE(SUM(luaslahan), 0) as area, COUNT(DISTINCT idlahan) as count").
		Scan(&totals)

	response.SummaryCards = []models.SummaryCardModel{
		{Label: "TOTAL POTENSI LAHAN", Value: totals.Area, Unit: "HA", Type: "potensi"},
		{Label: "TOTAL LOKASI", Value: float64(totals.Count), Unit: "LOKASI", Type: "lokasi"},
	}

	// 2. Summary Lahan, Tanam, Panen
	response.LahanSummary = []models.LahanSummaryModel{
		getSummaryData(applyDashboardFilters(initializers.DB.Model(&models.Lahan{}), c), "Total Potensi Lahan", "#0D47A1", []string{"1", "2", "3", "4"}),
		getTransactionSummary(c, "Total Lahan Tanam", "#2E7D32", "tanam", "luastanam", "tgltanam", tglMulai, tglSelesai),
		getTransactionSummary(c, "Total Lahan Panen", "#C62828", "panen", "luaspanen", "tglpanen", tglMulai, tglSelesai),
	}

	// 3. Grafik & Statistik
	response.HarvestSummary = getHarvestGrowthSummary(c)
	response.QuarterlyData = getQuarterlySummary(c)
	response.ResapanYearly = getResapanSummary(c)

	// 4. Distribusi Wilayah
	var admin models.DistributionModel
	admin.Label = "DISTRIBUSI WILAYAH"
	initializers.DB.Table("wilayah").Select("SUM(CASE WHEN CHAR_LENGTH(kode) > 8 THEN 1 ELSE 0 END)").Scan(&admin.Total)
	if admin.Items == nil {
		admin.Items = []models.DistributionItem{} // Keamanan Flutter
	}
	response.Distribution = append(response.Distribution, admin)

	// CATATAN PENTING: response.MapPotensi SENGAJA DIHAPUS dari sini agar JSON tidak raksasa!
	// MapPotensi memiliki endpoint sendiri (/api/dashboard/map-potensi)

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

func getSummaryData(db *gorm.DB, title string, color string, statusFilter []string) models.LahanSummaryModel {
	var totalArea float64
	var items []models.LahanDetailItem

	rows, err := db.Where("statuslahan IN ?", statusFilter).
		Select("idjenislahan, COALESCE(SUM(luaslahan), 0) as area, COUNT(DISTINCT idlahan) as count").
		Group("idjenislahan").Rows()

	if err == nil {
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
	}

	if items == nil {
		items = []models.LahanDetailItem{} // Null safety
	}

	return models.LahanSummaryModel{
		Title:           title,
		BackgroundColor: color,
		TotalValue:      totalArea,
		Items:           items,
	}
}

func getTransactionSummary(c *gin.Context, title, color, table, col, dateCol, tglMulai, tglSelesai string) models.LahanSummaryModel {
	var totalArea float64
	var items []models.LahanDetailItem

	query := initializers.DB.Table(table)

	if table == "panen" {
		query = query.Select("lahan.idjenislahan, COALESCE(SUM(panen.luaspanen), 0) as area, COUNT(DISTINCT lahan.idlahan) as count").
			Joins("JOIN tanam ON tanam.idtanam = panen.idtanam").
			Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
			Where("panen.deletestatus = ?", "2")
	} else {
		query = query.Select("lahan.idjenislahan, COALESCE(SUM("+table+"."+col+"), 0) as area, COUNT(DISTINCT lahan.idlahan) as count").
			Joins("JOIN lahan ON lahan.idlahan = "+table+".idlahan").
			Where(table+".deletestatus = ?", "2")
	}

	// Pastikan filter di-apply SETELAH JOIN Lahan selesai
	query = applyDashboardFilters(query, c)

	if tglMulai != "" && tglSelesai != "" {
		query = query.Where(table+"."+dateCol+" BETWEEN ? AND ?", tglMulai, tglSelesai)
	}

	rows, err := query.Group("lahan.idjenislahan").Rows()
	if err == nil {
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
	}

	if items == nil {
		items = []models.LahanDetailItem{}
	}

	return models.LahanSummaryModel{
		Title:           title,
		BackgroundColor: color,
		TotalValue:      totalArea,
		Items:           items,
	}
}

func getHarvestGrowthSummary(c *gin.Context) models.HarvestSummaryModel {
	currentYear := time.Now().Year()
	idKomoditi := c.Query("id_komoditi")
	jenisKomoditi := c.Query("jenis_komoditi")

	type komRow struct {
		ID   string `gorm:"column:idkomoditi"`
		Nama string `gorm:"column:namakomoditi"`
	}
	var koms []komRow

	komQ := initializers.DB.Table("komoditi").Select("idkomoditi, namakomoditi").Where("deletestatus = ?", "2")
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
		cat := &models.HarvestCategory{
			ID:    k.ID,
			Label: k.Nama,
			Color: colors[colorIdx%len(colors)],
		}
		colorIdx++
		for m := 1; m <= 12; m++ {
			cat.DataPoints = append(cat.DataPoints, models.HarvestPoint{Month: m, Year: currentYear, Value: 0})
		}
		catMap[k.ID] = cat
	}

	q := initializers.DB.Table("panen").
		Select("MONTH(panen.tglpanen) as m, YEAR(panen.tglpanen) as y, komoditi.idkomoditi as idk, SUM(panen.luaspanen) as total").
		Joins("JOIN tanam ON tanam.idtanam = panen.idtanam").
		Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
		Joins("JOIN komoditi ON komoditi.idkomoditi = lahan.idkomoditi").
		Where("panen.deletestatus = ? AND YEAR(panen.tglpanen) = ?", "2", currentYear)

	q = applyDashboardFilters(q, c) // Apply safe filters

	type aggRow struct {
		Month      int     `gorm:"column:m"`
		Year       int     `gorm:"column:y"`
		IDKomoditi string  `gorm:"column:idk"`
		TotalLuas  float64 `gorm:"column:total"`
	}
	var aggs []aggRow
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
				cat.DataPoints = append(cat.DataPoints, models.HarvestPoint{Month: m, Year: currentYear, Value: 0})
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
		categories = []models.HarvestCategory{}
	}

	return models.HarvestSummaryModel{TotalPanen: totalOverall, Unit: "HA", Categories: categories}
}

func getQuarterlySummary(c *gin.Context) []models.QuarterlyItemModel {
	currentYear := time.Now().Year()
	quarterLabels := []string{"KW1", "KW2", "KW3", "KW4"}

	qTanam := initializers.DB.Table("tanam").
		Select("QUARTER(tgltanam) as q, COALESCE(SUM(luastanam), 0) as total").
		Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
		Where("tanam.deletestatus = ? AND YEAR(tgltanam) = ?", "2", currentYear)
	qTanam = applyDashboardFilters(qTanam, c)

	qPanen := initializers.DB.Table("panen").
		Select("QUARTER(tglpanen) as q, COALESCE(SUM(luaspanen), 0) as total").
		Joins("JOIN tanam ON tanam.idtanam = panen.idtanam").
		Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
		Where("panen.deletestatus = ? AND YEAR(tglpanen) = ?", "2", currentYear)
	qPanen = applyDashboardFilters(qPanen, c)

	var resTanam, resPanen []struct {
		Q     int
		Total float64
	}
	qTanam.Group("q").Scan(&resTanam)
	qPanen.Group("q").Scan(&resPanen)

	mapTanam := map[int]float64{1: 0, 2: 0, 3: 0, 4: 0}
	mapPanen := map[int]float64{1: 0, 2: 0, 3: 0, 4: 0}

	for _, v := range resTanam {
		mapTanam[v.Q] = v.Total
	}
	for _, v := range resPanen {
		mapPanen[v.Q] = v.Total
	}

	items := []models.QuarterlyItemModel{}
	for i := 1; i <= 4; i++ {
		items = append(items, models.QuarterlyItemModel{Label: "Lahan Tanam", Value: mapTanam[i], Unit: "HA", Period: quarterLabels[i-1]})
		items = append(items, models.QuarterlyItemModel{Label: "Lahan Panen", Value: mapPanen[i], Unit: "HA", Period: quarterLabels[i-1]})
	}
	return items
}

func getResapanSummary(c *gin.Context) models.ResapanModel {
	currentYear := time.Now().Year()

	query := initializers.DB.Table("tanam").
		Select("lahan.idjenislahan as idj, COALESCE(SUM(tanam.luastanam), 0) as total").
		Joins("JOIN lahan ON lahan.idlahan = tanam.idlahan").
		Where("tanam.deletestatus = ? AND YEAR(tanam.tgltanam) = ?", "2", currentYear)
	query = applyDashboardFilters(query, c)

	var results []struct {
		IDJenis int     `gorm:"column:idj"`
		Total   float64 `gorm:"column:total"`
	}
	query.Group("idj").Scan(&results)

	items := []models.ResapanItem{}
	var grandTotal float64
	for _, res := range results {
		items = append(items, models.ResapanItem{Label: getLahanLabel(res.IDJenis), Value: res.Total})
		grandTotal += res.Total
	}

	return models.ResapanModel{Year: fmt.Sprintf("%d", currentYear), Total: grandTotal, Items: items}
}

// ==============================
// FILTER & MAP ENDPOINTS
// ==============================

func GetJenisKomoditiFilter(c *gin.Context) {
	var out []string
	if err := initializers.DB.Table("komoditi").Select("DISTINCT jeniskomoditi").
		Where("deletestatus = ? AND jeniskomoditi IS NOT NULL AND jeniskomoditi <> ''", "2").
		Order("jeniskomoditi ASC").Pluck("jeniskomoditi", &out).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": out})
}

func GetKomoditiByJenisFilter(c *gin.Context) {
	jenisKomoditi := c.Query("jenis_komoditi")
	q := initializers.DB.Table("komoditi").Select("idkomoditi as id, namakomoditi as label").Where("deletestatus = ?", "2")
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

func GetDashboardMapPotensi(c *gin.Context) {
	baseQuery := initializers.DB.Model(&models.Lahan{})
	baseQuery = applyDashboardFilters(baseQuery, c)
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": getMapPotensiSummary(baseQuery)})
}

func getMapPotensiSummary(db *gorm.DB) models.MapPotensiModel {
	const LIMIT = 2000
	type row struct {
		IDLahan     string  `gorm:"column:idlahan"`
		Lat         float64 `gorm:"column:lat"`
		Lng         float64 `gorm:"column:lng"`
		LuasLahan   float64 `gorm:"column:luaslahan"`
		StatusLahan string  `gorm:"column:statuslahan"`
		IDJenis     int     `gorm:"column:idjenislahan"`
		IDKomoditi  *string `gorm:"column:idkomoditi"`
		NamaKom     *string `gorm:"column:namakomoditi"`
		JenisKom    *string `gorm:"column:jeniskomoditi"`
		KodeWil     *string `gorm:"column:idwilayah"`
		NamaWil     *string `gorm:"column:namawilayah"`
	}

	var rows []row
	q := db.Select(`lahan.idlahan, lahan.lat, lahan.longi as lng, COALESCE(lahan.luaslahan, 0) as luaslahan, lahan.statuslahan, lahan.idjenislahan, komoditi.idkomoditi, komoditi.namakomoditi, komoditi.jeniskomoditi, lahan.idwilayah, w.nama as namawilayah`).
		Joins(`LEFT JOIN komoditi ON komoditi.idkomoditi = lahan.idkomoditi AND komoditi.deletestatus = '2'`).
		Joins(`LEFT JOIN wilayah w ON w.kode = lahan.idwilayah`).
		Where(`lahan.statuslahan IN ('1','2','3','4')`).
		Where("lahan.lat IS NOT NULL AND lahan.longi IS NOT NULL AND lahan.lat <> 0 AND lahan.longi <> 0").
		Order("lahan.idlahan DESC").Limit(LIMIT)

	if err := q.Scan(&rows).Error; err != nil || len(rows) == 0 {
		return models.MapPotensiModel{TotalPoints: 0, Points: []models.MapPotensiItem{}}
	}

	out := make([]models.MapPotensiItem, 0, len(rows))
	for _, r := range rows {
		out = append(out, models.MapPotensiItem{
			IDLahan: r.IDLahan, Lat: r.Lat, Lng: r.Lng, LuasLahan: r.LuasLahan,
			StatusLahan: r.StatusLahan, JenisLahan: getLahanLabel(r.IDJenis),
			IDKomoditi: r.IDKomoditi, NamaKomoditi: r.NamaKom, JenisKomoditi: r.JenisKom,
			KodeWilayah: r.KodeWil, NamaWilayah: r.NamaWil,
		})
	}
	return models.MapPotensiModel{TotalPoints: int64(len(out)), Points: out}
}
