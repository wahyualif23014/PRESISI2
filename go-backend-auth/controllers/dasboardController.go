package controllers

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

func GetDashboardData(c *gin.Context) {
	// 1. Ambil Parameter Filter
	resor := c.Query("resor")
	sektor := c.Query("sektor")
	idJenis := c.Query("id_jenis_lahan")
	idKomoditi := c.Query("id_komoditi")
	tahun := c.Query("tahun")
	kwartal := c.Query("kwartal")
	tglMulai := c.Query("tanggal_mulai")
	tglSelesai := c.Query("tanggal_selesai")

	// 2. Inisialisasi Query Base untuk tabel Lahan
	db := initializers.DB.Table("lahan").Where("statuslahan IN ('1', '2', '3', '4')")

	// Filter Wilayah
	if sektor != "" {
		sName := strings.ReplaceAll(strings.ToUpper(sektor), "POLSEK ", "")
		db = db.Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = SUBSTR(lahan.idwilayah, 1, 8)").
			Where("UPPER(w_kec.nama) LIKE ?", "%"+sName+"%")
	} else if resor != "" {
		rName := strings.ReplaceAll(strings.ToUpper(resor), "POLRES ", "")
		db = db.Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah, 1, 5)").
			Where("UPPER(w_kab.nama) LIKE ?", "%"+rName+"%")
	}

	// Filter Jenis & Komoditi
	if idJenis != "" {
		db = db.Where("idjenislahan = ?", idJenis)
	}
	if idKomoditi != "" {
		db = db.Where("idkomoditi = ?", idKomoditi)
	}

	// Filter Periode
	activeFilterLabel := "TOTAL POTENSI LAHAN"
	if tglMulai != "" && tglSelesai != "" {
		db = db.Where("datetransaction BETWEEN ? AND ?", tglMulai, tglSelesai)
		activeFilterLabel = fmt.Sprintf("PERIODE %s S/D %s", tglMulai, tglSelesai)
	} else if kwartal != "" && tahun != "" {
		startMonth, endMonth := getQuarterRange(kwartal)
		db = db.Where("tahunlahan = ? AND MONTH(datetransaction) BETWEEN ? AND ?", tahun, startMonth, endMonth)
		activeFilterLabel = fmt.Sprintf("%s TAHUN %s", strings.ToUpper(kwartal), tahun)
	} else if tahun != "" {
		db = db.Where("tahunlahan = ?", tahun)
		activeFilterLabel = fmt.Sprintf("SAMPAI TAHUN %s", tahun)
	}

	var response models.DashboardDataResponse
	response.ActiveFilterLabel = activeFilterLabel

	// 3. GENERATE SUMMARY CARDS (Bagian Atas Dashboard)
	var totals struct {
		Area  float64
		Count int64
	}
	db.Select("COALESCE(SUM(luaslahan), 0) as area, COUNT(DISTINCT idlahan) as count").Scan(&totals)

	response.SummaryCards = []models.SummaryCardModel{
		{Label: "TOTAL POTENSI LAHAN", Value: totals.Area, Unit: "HA", Type: "potensi"},
		{Label: "TOTAL LOKASI", Value: float64(totals.Count), Unit: "LOKASI", Type: "lokasi"},
	}

	// 4. GENERATE LAHAN SUMMARY (Ringkasan Area Lahan)
	groups := make(map[string]*models.LahanSummaryModel)
	
	// FIX: Key disamakan agar colors[g] tidak kosong (Penyebab FormatException di Flutter)
	mainGroups := []string{"PRODUKTIF", "HUTAN", "LBS", "PESANTREN", "MILIK POLRI", "LAINNYA"}
	colors := map[string]string{
		"PRODUKTIF": "#2E7D32", 
		"HUTAN":     "#1B5E20", 
		"LBS":       "#43A047", 
		"PESANTREN": "#689F38", 
		"MILIK POLRI": "#0D47A1", 
		"LAINNYA":   "#757575",
	}

	for _, g := range mainGroups {
		displayTitle := g
		if g == "LBS" { displayTitle = "LUAS BAKU SAWAH (LBS)" }
		groups[g] = &models.LahanSummaryModel{
			Title:           displayTitle, 
			BackgroundColor: colors[g], 
			Items:           []models.LahanDetailItem{},
		}
	}

	rows, _ := db.Select("idjenislahan, COALESCE(SUM(luaslahan), 0) as area, COUNT(DISTINCT idlahan) as count").
		Group("idjenislahan").Rows()
	
	defer rows.Close()
	for rows.Next() {
		var id int
		var area float64
		var count int64
		rows.Scan(&id, &area, &count)

		item := models.LahanDetailItem{Value: area, Count: count}
		var targetGroup string

		switch id {
		case 2:
			item.Label = "POKTAN BINAAN POLRI"
			targetGroup = "PRODUKTIF"
		case 6:
			item.Label = "MASYARAKAT BINAAN POLRI"
			targetGroup = "PRODUKTIF"
		case 7:
			item.Label = "TUMPANG SARI"
			targetGroup = "PRODUKTIF"
		case 1:
			item.Label = "PERHUTANAN SOSIAL"
			targetGroup = "HUTAN"
		case 8:
			item.Label = "PERHUTANI/INHUTANI"
			targetGroup = "HUTAN"
		case 3:
			item.Label = "LBS"
			targetGroup = "LBS"
		case 4:
			item.Label = "PESANTREN"
			targetGroup = "PESANTREN"
		case 5:
			item.Label = "MILIK POLRI"
			targetGroup = "MILIK POLRI"
		default:
			item.Label = "LAINNYA"
			targetGroup = "LAINNYA"
		}

		if groups[targetGroup] != nil {
			groups[targetGroup].Items = append(groups[targetGroup].Items, item)
			groups[targetGroup].TotalValue += area
		}
	}

	for _, g := range mainGroups {
		if groups[g].TotalValue > 0 {
			response.LahanSummary = append(response.LahanSummary, *groups[g])
		}
	}

	// 5. GENERATE DISTRIBUTION DATA (Statistik Wilayah)
	var admin models.DistributionModel
	admin.Label = "DISTRIBUSI WILAYAH"
	initializers.DB.Table("wilayah").Select("SUM(CASE WHEN CHAR_LENGTH(kode) > 8 THEN 1 ELSE 0 END)").Scan(&admin.Total)
	response.Distribution = append(response.Distribution, admin)

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   response,
	})
}

func getQuarterRange(kwartal string) (int, int) {
	switch strings.ToUpper(kwartal) {
	case "KW1":
		return 1, 3
	case "KW2":
		return 4, 6
	case "KW3":
		return 7, 9
	case "KW4":
		return 10, 12
	default:
		return 1, 12
	}
}