package controllers

import (
	"encoding/base64"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

func GetImageFromDB(c *gin.Context) {
	filenameRaw := c.Param("filename")
	filename, err := url.QueryUnescape(filenameRaw)
	if err != nil {
		filename = filenameRaw
	}

	var lahan models.PotensiLahan
	result := initializers.DB.Table("lahan").Where("dokumentasi = ?", filename).First(&lahan)

	if result.Error != nil {
		fmt.Printf("[ERROR] Data tidak ditemukan untuk file: %s\n", filename)
		c.JSON(http.StatusNotFound, gin.H{"error": "Data SQL tidak ditemukan"})
		return
	}

	base64String := lahan.Foto
	if base64String == "" {
		c.JSON(http.StatusNotFound, gin.H{"error": "Kolom SQL kosong"})
		return
	}

	if strings.Contains(base64String, ",") {
		base64String = strings.Split(base64String, ",")[1]
	}

	base64String = strings.TrimSpace(base64String)
	base64String = strings.ReplaceAll(base64String, "\n", "")
	base64String = strings.ReplaceAll(base64String, "\r", "")

	imageBytes, err := base64.StdEncoding.DecodeString(base64String)
	if err != nil {
		imageBytes, err = base64.RawStdEncoding.DecodeString(base64String)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Base64 Rusak", "debug": err.Error()})
			return
		}
	}

	c.Data(http.StatusOK, "image/jpeg", imageBytes)
}

func GetPotensiLahan(c *gin.Context) {
	var daftarLahan []models.PotensiLahan

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	offset := (page - 1) * limit

	search := c.Query("search")
	polres := c.Query("polres")
	polsek := c.Query("polsek")

	db := initializers.DB.Table("lahan").
		Select(`
			lahan.*, 
			w_desa.nama AS nama_desa, 
			w_kec.nama AS nama_kecamatan, 
			w_kab.nama AS nama_kabupaten,
			p.nama AS nama_pemroses, 
			v.nama AS nama_validator,
			akt.nama AS nama_poktan_asli,
			k.jeniskomoditi AS jenis_komoditas_nama,
			k.namakomoditi AS nama_komoditi_asli
		`).
		Joins("LEFT JOIN wilayah w_desa ON w_desa.kode = lahan.idwilayah").
		Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = SUBSTR(lahan.idwilayah, 1, 8)").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah, 1, 5)").
		Joins("LEFT JOIN anggota p ON p.idanggota = lahan.editoleh").
		Joins("LEFT JOIN anggota v ON v.idanggota = lahan.validoleh").
		Joins("LEFT JOIN anggota akt ON akt.idanggota = lahan.poktan").
		Joins("LEFT JOIN komoditi k ON k.idkomoditi = lahan.idkomoditi").
		Where("lahan.statuslahan IS NOT NULL AND lahan.statuslahan IN ('1', '2', '3', '4')")

	if search != "" {
		s := "%" + strings.ToLower(search) + "%"
		db = db.Where("LOWER(lahan.alamat) LIKE ? OR LOWER(lahan.ketcp) LIKE ?", s, s)
	}

	if polres != "" {
		db = db.Where("w_kab.nama = ?", polres)
	}
	if polsek != "" {
		db = db.Where("w_kec.nama = ?", polsek)
	}

	if err := db.Order("lahan.tgledit DESC").Limit(limit).Offset(offset).Find(&daftarLahan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": daftarLahan})
}

func ToggleValidation(c *gin.Context) {
	id := c.Param("id")
	currentUserID, exists := c.Get("user_id")
	if !exists {
		var body struct {
			ValidatorID string `json:"validator_id"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			currentUserID = "0"
		} else {
			currentUserID = body.ValidatorID
		}
	}

	var lahan models.PotensiLahan
	if err := initializers.DB.Table("lahan").Where("idlahan = ?", id).First(&lahan).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data tidak ditemukan"})
		return
	}

	updates := map[string]interface{}{}
	if lahan.StatusLahan == "2" {
		updates["validoleh"] = nil
		updates["tglvalid"] = nil
		updates["statuslahan"] = "1"
		initializers.DB.Table("lahan").Where("idlahan = ?", id).Select("validoleh", "tglvalid", "statuslahan").Updates(updates)
		c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Validasi berhasil dibatalkan"})
	} else {
		updates["validoleh"] = currentUserID
		updates["tglvalid"] = time.Now().Format("2006-01-02 15:04:05")
		updates["statuslahan"] = "2"
		initializers.DB.Table("lahan").Where("idlahan = ?", id).Updates(updates)
		c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Data berhasil divalidasi"})
	}
}

func GetFilterOptions(c *gin.Context) {
	var rawPolres []string
	var rawPolsek []string
	polresParam := c.Query("polres")

	initializers.DB.Table("lahan").
		Select("DISTINCT w_kab.nama").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah, 1, 5)").
		Where("w_kab.nama IS NOT NULL").
		Order("w_kab.nama ASC").
		Pluck("w_kab.nama", &rawPolres)

	var listPolres []string
	for _, v := range rawPolres {
		name := strings.ToUpper(v)
		name = strings.ReplaceAll(name, "KABUPATEN", "")
		name = strings.ReplaceAll(name, "KOTA", "")
		name = strings.TrimSpace(name)
		listPolres = append(listPolres, fmt.Sprintf("POLRES %s", name))
	}

	queryPolsek := initializers.DB.Table("lahan").
		Select("DISTINCT w_kec.nama").
		Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = SUBSTR(lahan.idwilayah, 1, 8)").
		Where("w_kec.nama IS NOT NULL")

	if polresParam != "" {
		dbParam := strings.ToUpper(polresParam)
		dbParam = strings.ReplaceAll(dbParam, "POLRES", "")
		dbParam = strings.TrimSpace(dbParam)
		queryPolsek = queryPolsek.
			Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah, 1, 5)").
			Where("UPPER(w_kab.nama) LIKE ?", "%"+dbParam+"%")
	}

	queryPolsek.Order("w_kec.nama ASC").Pluck("w_kec.nama", &rawPolsek)

	var listPolsek []string
	for _, v := range rawPolsek {
		listPolsek = append(listPolsek, fmt.Sprintf("POLSEK %s", strings.ToUpper(v)))
	}

	var listJenis []string
	rows, err := initializers.DB.Table("lahan").Select("idjenislahan").Group("idjenislahan").Order("idjenislahan ASC").Rows()
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
			listJenis = append(listJenis, title)
		}
	}

	c.JSON(200, gin.H{"status": "success", "data": gin.H{"polres": listPolres, "polsek": listPolsek, "jenis_lahan": listJenis}})
}

func CreatePotensiLahan(c *gin.Context) {
	var input models.PotensiLahan
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": err.Error()})
		return
	}
	input.DateTransaction = time.Now()
	if err := initializers.DB.Table("lahan").Create(&input).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"status": "success", "data": input})
}

func UpdatePotensiLahan(c *gin.Context) {
	id := c.Param("id")
	var input models.PotensiLahan
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": err.Error()})
		return
	}

	updates := map[string]interface{}{
		"idwilayah":    input.IDWilayah,
		"idjenislahan": input.IDJenisLahan,
		"alamat":       input.AlamatLahan,
		"luaslahan":    input.LuasLahan,
		"poktan":       input.JumlahPoktan,
		"jmlsantri":    input.JumlahPetani,
		"ketcp":        input.Keterangan,
		"keterangan":   input.KeteranganLain,
		"cp":           input.CPName,
		"hp":           input.CPPhone,
		"cppolisi":     input.PolisiName,
		"hppolisi":     input.PolisiPhone,
		"lat":          input.Latitude,
		"longi":        input.Longitude,
		"dokumentasi":  input.Foto,
		"editoleh":     input.EditOleh,
		"tgledit":      time.Now().Format("2006-01-02 15:04:05"),
	}

	if err := initializers.DB.Table("lahan").Where("idlahan = ?", id).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Data berhasil diperbarui"})
}

func DeletePotensiLahan(c *gin.Context) {
	id := c.Param("id")
	if err := initializers.DB.Table("lahan").Delete(&models.PotensiLahan{}, "idlahan = ?", id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Data berhasil dihapus"})
}

func GetSummaryLahan(c *gin.Context) {
	type SummaryCategory struct {
		Title string  `json:"title"`
		Area  float64 `json:"area"`
		Count int64   `json:"count"`
	}
	var totals struct {
		TotalArea float64 `gorm:"column:total_area"`
		TotalLoc  int64   `gorm:"column:total_loc"`
	}
	dbFilter := "idwilayah IS NOT NULL AND statuslahan IN ('1', '2', '3', '4')"
	initializers.DB.Table("lahan").Where(dbFilter).Select("COALESCE(SUM(luaslahan), 0) as total_area, COUNT(DISTINCT idlahan) as total_loc").Scan(&totals)

	var categories []SummaryCategory
	rows, err := initializers.DB.Table("lahan").Where(dbFilter).Select("idjenislahan, COALESCE(SUM(luaslahan), 0) as area, COUNT(DISTINCT idlahan) as count").Group("idjenislahan").Rows()
	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var id int
			var area float64
			var count int64
			rows.Scan(&id, &area, &count)
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
			categories = append(categories, SummaryCategory{Title: title, Area: area, Count: count})
		}
	}
	c.JSON(http.StatusOK, gin.H{"status": "success", "data": gin.H{"total_area": totals.TotalArea, "total_locations": totals.TotalLoc, "categories": categories}})
}

func GetNoPotentialLahan(c *gin.Context) {
	var master struct {
		Kab  int64
		Kec  int64
		Desa int64
	}
	initializers.DB.Table("wilayah").Select("SUM(CASE WHEN CHAR_LENGTH(kode) = 5 THEN 1 ELSE 0 END) as kab, SUM(CASE WHEN CHAR_LENGTH(kode) = 8 THEN 1 ELSE 0 END) as kec, SUM(CASE WHEN CHAR_LENGTH(kode) > 8 THEN 1 ELSE 0 END) as desa").Scan(&master)

	var isi struct {
		Kab  int64
		Kec  int64
		Desa int64
	}
	dbFilter := "idwilayah IS NOT NULL AND statuslahan IN ('1', '2', '3', '4')"
	initializers.DB.Table("lahan").Where(dbFilter).Select("COUNT(DISTINCT SUBSTR(idwilayah, 1, 5)) as kab, COUNT(DISTINCT SUBSTR(idwilayah, 1, 8)) as kec, COUNT(DISTINCT idwilayah) as desa").Scan(&isi)

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": gin.H{"total_empty_polres": master.Kab - isi.Kab, "details": gin.H{"polsek": master.Kec - isi.Kec, "kab_kota": master.Kab - isi.Kab, "kecamatan": master.Kec - isi.Kec, "kel_desa": master.Desa - isi.Desa}}})
}

func ValidatePotensiLahan(c *gin.Context) {
	id := c.Param("id")
	var body struct {
		ValidatorID string `json:"validator_id"`
	}
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Validator ID diperlukan"})
		return
	}
	updates := map[string]interface{}{"validoleh": body.ValidatorID, "tglvalid": time.Now().Format("2006-01-02 15:04:05"), "statuslahan": "2"}
	initializers.DB.Table("lahan").Where("idlahan = ?", id).Updates(updates)
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Data berhasil divalidasi"})
}

func UnvalidatePotensiLahan(c *gin.Context) {
	id := c.Param("id")
	updates := map[string]interface{}{"validoleh": nil, "tglvalid": nil, "statuslahan": "1"}
	initializers.DB.Table("lahan").Where("idlahan = ?", id).Select("validoleh", "tglvalid", "statuslahan").Updates(updates)
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Validasi berhasil dibatalkan"})
}
