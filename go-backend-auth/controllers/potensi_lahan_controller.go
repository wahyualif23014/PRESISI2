package controllers

import (
	"encoding/base64"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

func GetImageFromDB(c *gin.Context) {
	rawFilename := c.Param("filename")
	filename, err := url.QueryUnescape(rawFilename)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Filename tidak valid"})
		return
	}

	var lahan models.PotensiLahan
	err = initializers.DB.
		Table("lahan").
		Where("dokumentasi = ?", filename).
		First(&lahan).Error

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data tidak ditemukan"})
		return
	}
	filePath := filepath.Join("uploads", lahan.Foto)

	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		c.JSON(http.StatusNotFound, gin.H{"error": "File tidak ditemukan"})
		return
	}

	c.File(filePath)
}

func GetPotensiLahan(c *gin.Context) {
	var daftarLahan []models.PotensiLahan

	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	offset := (page - 1) * limit

	search := c.Query("search")
	polres := c.Query("polres")
	polsek := c.Query("polsek")
	jenisLahan := c.Query("jenis_lahan")
	statusVal := c.Query("status")

	db := initializers.DB.Table("lahan").
		Select("lahan.*, w_desa.nama_wilayah AS nama_desa, w_kec.nama_wilayah AS nama_kecamatan, w_kab.nama_wilayah AS nama_kabupaten, p.nama_anggota AS nama_pemroses, v.nama_anggota AS nama_validator, akt.nama_anggota AS nama_poktan_asli, k.jenis_komoditi AS jenis_komoditas_nama, k.nama_komoditi AS nama_komoditi_asli").
		Joins("LEFT JOIN wilayah w_desa ON w_desa.id_wilayah = lahan.id_wilayah").
		Joins("LEFT JOIN wilayah w_kec ON w_kec.id_wilayah = SUBSTR(lahan.id_wilayah, 1, 8)").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.id_wilayah = SUBSTR(lahan.id_wilayah, 1, 5)").
		Joins("LEFT JOIN anggota p ON CAST(p.username AS CHAR) = CAST(lahan.edit_oleh AS CHAR)").
		Joins("LEFT JOIN anggota v ON CAST(v.username AS CHAR) = CAST(lahan.valid_oleh AS CHAR)").
		Joins("LEFT JOIN anggota akt ON akt.id_anggota = lahan.poktan").
		Joins("LEFT JOIN komoditi k ON k.id_komoditi = lahan.id_komoditi").
		Where("lahan.status_lahan IS NOT NULL AND lahan.status_lahan IN ('1', '2', '3', '4')")

	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		db = db.Where("lahan.id_tingkat LIKE ?", user.IDTugas+"%")
	}

	if search != "" {
		s := "%" + strings.ToLower(search) + "%"
		db = db.Where("(LOWER(lahan.alamat_lahan) LIKE ? OR LOWER(lahan.cp_lahan) LIKE ?)", s, s)
	}

	if polres != "" {
		p := strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(polres), "POLRES", ""))
		db = db.Where("UPPER(w_kab.nama_wilayah) LIKE ?", "%"+p+"%")
	}

	if polsek != "" {
		ps := strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(polsek), "POLSEK", ""))
		db = db.Where("UPPER(w_kec.nama_wilayah) LIKE ?", "%"+ps+"%")
	}

	if jenisLahan != "" {
		idJenis := 0
		jl := strings.ToUpper(strings.TrimSpace(jenisLahan))
		switch jl {
		case "PRODUKTIF (POKTAN BINAAN POLRI)":
			idJenis = 1
		case "HUTAN (PERHUTANAN SOSIAL)":
			idJenis = 2
		case "LUAS BAKU SAWAH (LBS)":
			idJenis = 3
		case "PESANTREN":
			idJenis = 4
		case "MILIK POLRI":
			idJenis = 5
		case "PRODUKTIF (MASYARAKAT BINAAN POLRI)":
			idJenis = 6
		case "PRODUKTIF (TUMPANG SARI)":
			idJenis = 7
		case "HUTAN (PERHUTANAN/INHUTANI)":
			idJenis = 8
		case "LAHAN LAINNYA":
			idJenis = 9
		}
		if idJenis > 0 {
			db = db.Where("lahan.id_jenis_lahan = ?", idJenis)
		}
	}

	if statusVal != "" {
		if statusVal == "Sudah Divalidasi" {
			db = db.Where("lahan.valid_oleh IS NOT NULL AND lahan.valid_oleh != '' AND lahan.valid_oleh != '0'")
		} else if statusVal == "Belum Divalidasi" {
			db = db.Where("(lahan.valid_oleh IS NULL OR lahan.valid_oleh = '' OR lahan.valid_oleh = '0')")
		}
	}

	if err := db.Order("lahan.tgl_edit DESC").Limit(limit).Offset(offset).Find(&daftarLahan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": daftarLahan})
}

func ToggleValidation(c *gin.Context) {
	var body struct {
		IDLahan int `json:"id_lahan"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Format request tidak valid"})
		return
	}

	if body.IDLahan == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "ID Lahan tidak boleh kosong"})
		return
	}

	var validatorID int
	if userID, exists := c.Get("user_id"); exists {
		switch v := userID.(type) {
		case string:
			validatorID, _ = strconv.Atoi(v)
		case float64:
			validatorID = int(v)
		case int:
			validatorID = v
		}
	}

	var currentStatus string
	err := initializers.DB.Table("lahan").Where("id_lahan = ?", body.IDLahan).Select("status_lahan").Row().Scan(&currentStatus)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Data lahan tidak ditemukan di database"})
		return
	}

	updates := map[string]interface{}{}

	if currentStatus == "2" {
		updates["valid_oleh"] = 0
		updates["tgl_valid"] = nil
		updates["status_lahan"] = "1"
	} else {
		updates["valid_oleh"] = validatorID
		updates["tgl_valid"] = time.Now().Format("2006-01-02 15:04:05")
		updates["status_lahan"] = "2"
	}

	result := initializers.DB.Table("lahan").Where("id_lahan = ?", body.IDLahan).Updates(updates)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Gagal menyimpan ke database: " + result.Error.Error()})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Data tidak berhasil diubah"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "Status validasi berhasil diperbarui",
	})
}

func resolveTingkatToWilayah(idTingkat string) string {
	var idWilayah string
	if len(idTingkat) >= 8 {
		// Polsek: lookup directly
		initializers.DB.Table("tingkatwilayah").
			Select("id_wilayah").
			Where("id_tingkat = ? AND deletestatus = '2'", idTingkat).
			Limit(1).
			Scan(&idWilayah)
	} else if len(idTingkat) >= 5 {
		// Polres: find any Polsek under it and get its parent BPS code
		var tempWilayah string
		initializers.DB.Table("tingkatwilayah").
			Select("id_wilayah").
			Where("id_tingkat LIKE ? AND deletestatus = '2'", idTingkat+"%").
			Limit(1).
			Scan(&tempWilayah)
		if len(tempWilayah) >= 5 {
			idWilayah = tempWilayah[:5]
		}
	}
	return idWilayah
}

func GetFilterOptions(c *gin.Context) {
	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	polresParam := c.Query("polres")
	polsekParam := c.Query("polsek")

	type WilayahData struct {
		Nama string `json:"nama" gorm:"column:nama_wilayah"`
		Kode string `json:"kode" gorm:"column:id_wilayah"`
	}

	var rawPolres []WilayahData
	queryPolres := initializers.DB.Table("wilayah").
		Select("nama_wilayah, id_wilayah").
		Where("CHAR_LENGTH(id_wilayah) = 5")
	
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		bpsPolres := resolveTingkatToWilayah(user.IDTugas)
		if len(bpsPolres) >= 5 {
			queryPolres = queryPolres.Where("id_wilayah = ?", bpsPolres[:5])
		}
	}
	queryPolres.Order("nama_wilayah ASC").Scan(&rawPolres)

	var listPolres []map[string]interface{}
	for _, v := range rawPolres {
		name := strings.ToUpper(v.Nama)
		name = strings.ReplaceAll(name, "KABUPATEN", "")
		name = strings.ReplaceAll(name, "KOTA", "")
		name = strings.TrimSpace(name)
		listPolres = append(listPolres, map[string]interface{}{
			"nama": fmt.Sprintf("POLRES %s", name),
			"kode": v.Kode,
		})
	}

	var listPolsek []map[string]interface{}
	var listDesa []map[string]interface{}
	var kabKode string

	if polresParam != "" {
		dbParam := strings.ToUpper(polresParam)
		dbParam = strings.ReplaceAll(dbParam, "POLRES", "")
		dbParam = strings.TrimSpace(dbParam)

		initializers.DB.Table("wilayah").
			Select("id_wilayah").
			Where("CHAR_LENGTH(id_wilayah) = 5 AND UPPER(nama_wilayah) LIKE ?", "%"+dbParam+"%").
			Limit(1).
			Pluck("id_wilayah", &kabKode)
	}

	if kabKode != "" || (user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "") {
		// If Operator Polsek/Polres, lock or resolve kabKode
		if kabKode == "" && user.IDTugas != "" {
			bpsPolres := resolveTingkatToWilayah(user.IDTugas)
			if len(bpsPolres) >= 5 {
				kabKode = bpsPolres[:5]
			}
		}

		var rawPolsek []WilayahData
		queryPolsekRaw := initializers.DB.Table("wilayah").
			Select("nama_wilayah, id_wilayah").
			Where("CHAR_LENGTH(id_wilayah) = 8 AND id_wilayah LIKE ?", kabKode+".%")
		
		if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
			bpsPolsek := resolveTingkatToWilayah(user.IDTugas)
			if len(bpsPolsek) >= 8 {
				queryPolsekRaw = queryPolsekRaw.Where("id_wilayah = ?", bpsPolsek[:8])
			}
		}

		queryPolsekRaw.Order("nama_wilayah ASC").Scan(&rawPolsek)

		for _, v := range rawPolsek {
			listPolsek = append(listPolsek, map[string]interface{}{
				"nama": fmt.Sprintf("POLSEK %s", strings.ToUpper(v.Nama)),
				"kode": v.Kode,
			})
		}
	}

	var kecKode string
	if polsekParam != "" || (user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && len(user.IDTugas) >= 8) {
		if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && len(user.IDTugas) >= 8 {
			bpsPolsek := resolveTingkatToWilayah(user.IDTugas)
			if len(bpsPolsek) >= 8 {
				kecKode = bpsPolsek
			}
		}

		if kecKode == "" && polsekParam != "" {
			dbParam := strings.ToUpper(polsekParam)
			dbParam = strings.ReplaceAll(dbParam, "POLSEK", "")
			dbParam = strings.TrimSpace(dbParam)

			query := initializers.DB.Table("wilayah").
				Select("id_wilayah").
				Where("CHAR_LENGTH(id_wilayah) = 8 AND UPPER(nama_wilayah) LIKE ?", "%"+dbParam+"%")
				
			if kabKode != "" {
				query = query.Where("id_wilayah LIKE ?", kabKode+".%")
			}
			
			query.Limit(1).Pluck("id_wilayah", &kecKode)
		}
	}

	if kecKode != "" {
		var rawDesa []WilayahData
		initializers.DB.Table("wilayah").
			Select("nama_wilayah, id_wilayah").
			Where("CHAR_LENGTH(id_wilayah) > 8 AND id_wilayah LIKE ?", kecKode+".%").
			Order("nama_wilayah ASC").
			Scan(&rawDesa)

		for _, v := range rawDesa {
			listDesa = append(listDesa, map[string]interface{}{
				"nama": strings.ToUpper(v.Nama),
				"kode": v.Kode,
			})
		}
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

	var listKomoditi []map[string]interface{}
	initializers.DB.Table("komoditi").
		Select("id_komoditi AS id, jenis_komoditi AS jenis, nama_komoditi AS nama").
		Order("jenis_komoditi ASC, nama_komoditi ASC").
		Find(&listKomoditi)

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data": gin.H{
			"polres":      listPolres,
			"polsek":      listPolsek,
			"desa":        listDesa,
			"jenis_lahan": listJenis,
			"komoditi":    listKomoditi,
		},
	})
}

func CreatePotensiLahan(c *gin.Context) {
	var input models.PotensiLahan
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": err.Error()})
		return
	}

	now := time.Now().Format("2006-01-02 15:04:05")
	input.DateTransaction = time.Now()
	input.TglEdit = now

	// Jika input.Foto berupa string Base64 yang panjang, decode dan simpan jadi file
	if len(input.Foto) > 500 {
		base64Str := input.Foto
		if strings.Contains(base64Str, ",") {
			parts := strings.Split(base64Str, ",")
			if len(parts) > 1 {
				base64Str = parts[1]
			}
		}
		decoded, err := base64.StdEncoding.DecodeString(base64Str)
		if err == nil {
			filename := fmt.Sprintf("lahan_%d.jpg", time.Now().UnixNano())
			filepathStr := filepath.Join("uploads", filename)
			os.MkdirAll("uploads", os.ModePerm)
			if err := os.WriteFile(filepathStr, decoded, 0644); err == nil {
				input.Foto = filename
			}
		}
	}

	// Resolve user and set IDTingkat
	var idTingkat string
	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		idTingkat = user.IDTugas
	} else {
		// Admin: resolve BPS desa code (first 8 chars) to Polsek id_tingkat
		if len(input.IDWilayah) >= 8 {
			kecBps := input.IDWilayah[:8]
			initializers.DB.Table("tingkatwilayah").
				Select("id_tingkat").
				Where("id_wilayah = ? AND deletestatus = '2'", kecBps).
				Limit(1).
				Scan(&idTingkat)
		}
	}
	input.IDTingkat = idTingkat

	// Perbaikan Error 1364: id_anggota otomatis diisi dengan ID/NRP user (EditOleh)
	var idAnggotaVal *int
	if input.IDAnggota != nil {
		idAnggotaVal = input.IDAnggota
	}

	db := initializers.DB.Table("lahan")

	var omitFields []string
	omitFields = append(omitFields, "id_lahan")
	if input.TglValid == "" || input.TglValid == "-" {
		omitFields = append(omitFields, "tgl_valid")
	}
	if input.ValidOleh == "" || input.ValidOleh == "0" || input.ValidOleh == "-" {
		omitFields = append(omitFields, "valid_oleh")
	}

	if len(omitFields) > 0 {
		db = db.Omit(omitFields...)
	}

	// We set IDAnggota to nil or pointer if needed
	input.IDAnggota = idAnggotaVal

	if err := db.Create(&input).Error; err != nil {
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

	// Jika input.Foto berupa string Base64 yang panjang, decode dan simpan jadi file
	if len(input.Foto) > 500 {
		base64Str := input.Foto
		if strings.Contains(base64Str, ",") {
			parts := strings.Split(base64Str, ",")
			if len(parts) > 1 {
				base64Str = parts[1]
			}
		}
		decoded, err := base64.StdEncoding.DecodeString(base64Str)
		if err == nil {
			filename := fmt.Sprintf("lahan_%d.jpg", time.Now().UnixNano())
			filepathStr := filepath.Join("uploads", filename)
			os.MkdirAll("uploads", os.ModePerm)
			if err := os.WriteFile(filepathStr, decoded, 0644); err == nil {
				input.Foto = filename
			}
		}
	}

	// Resolve user and set IDTingkat
	var idTingkat string
	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		idTingkat = user.IDTugas
	} else {
		// Admin: resolve BPS desa code (first 8 chars) to Polsek id_tingkat
		if len(input.IDWilayah) >= 8 {
			kecBps := input.IDWilayah[:8]
			initializers.DB.Table("tingkatwilayah").
				Select("id_tingkat").
				Where("id_wilayah = ? AND deletestatus = '2'", kecBps).
				Limit(1).
				Scan(&idTingkat)
		}
	}

	updates := map[string]interface{}{
		"id_tingkat":        idTingkat,
		"id_wilayah":        input.IDWilayah,
		"id_jenis_lahan":    input.IDJenisLahan,
		"id_komoditi":       input.IDKomoditi,
		"alamat_lahan":      input.AlamatLahan,
		"luas_lahan":        input.LuasLahan,
		"poktan":            input.JumlahPoktan,
		"jml_petani":        input.JumlahPetani,
		"keterangan_lahan":  input.Keterangan,
		"cp_lahan":          input.CPName,
		"no_cp_lahan":       input.CPPhone,
		"cp_polisi":         input.PolisiName,
		"no_cp_polisi":      input.PolisiPhone,
		"latitude":          input.Latitude,
		"longitude":         input.Longitude,
		"dokumentasi_lahan": input.Foto,
		"tgl_edit":          time.Now().Format("2006-01-02 15:04:05"),
		"edit_oleh":         input.EditOleh,
		"id_anggota":        input.IDAnggota,
	}

	if err := initializers.DB.Table("lahan").Where("id_lahan = ?", id).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Data berhasil diperbarui"})
}

func DeletePotensiLahan(c *gin.Context) {
	id := c.Param("id")
	if err := initializers.DB.Table("lahan").Delete(&models.PotensiLahan{}, "id_lahan = ?", id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Data berhasil dihapus"})
}

func GetSummaryLahan(c *gin.Context) {
	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	type SummaryCategory struct {
		Title string  `json:"title"`
		Area  float64 `json:"area"`
		Count int64   `json:"count"`
	}

	var totals struct {
		TotalArea float64 `gorm:"column:total_area"`
		TotalLoc  int64   `gorm:"column:total_loc"`
	}

	dbFilter := `
		deletestatus = '2'
		AND status_lahan = '1'
		AND id_jenis_lahan IS NOT NULL
	`
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		dbFilter += " AND id_tingkat LIKE '" + user.IDTugas + "%'"
	}

	initializers.DB.Table("lahan").
		Where(dbFilter).
		Select(`
			COALESCE(SUM(luas_lahan),0) as total_area,
			COUNT(id_lahan) as total_loc
		`).
		Scan(&totals)

	var categories []SummaryCategory

	rows, err := initializers.DB.Table("lahan").
		Where(dbFilter).
		Select(`
			id_jenis_lahan,
			COALESCE(SUM(luas_lahan),0) as area,
			COUNT(id_lahan) as count
		`).
		Group("id_jenis_lahan").
		Order("id_jenis_lahan ASC").
		Rows()

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
				title = "HUTAN (PERHUTANAN/INHUTANI)"
			}

			categories = append(categories, SummaryCategory{
				Title: title,
				Area:  area,
				Count: count,
			})
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data": gin.H{
			"total_area":      totals.TotalArea,
			"total_locations": totals.TotalLoc,
			"categories":      categories,
		},
	})
}

func GetNoPotentialLahan(c *gin.Context) {
	var user models.User
	if val, exists := c.Get("user"); exists {
		if u, ok := val.(models.User); ok {
			user = u
		}
	}

	var master struct {
		Kab  int64
		Kec  int64
		Desa int64
	}

	masterQuery := initializers.DB.Table("wilayah").
		Select(`
			COUNT(CASE WHEN LENGTH(id_wilayah) = 5 THEN 1 END) as kab,
			COUNT(CASE WHEN LENGTH(id_wilayah) = 8 THEN 1 END) as kec,
			COUNT(CASE WHEN LENGTH(id_wilayah) > 8 THEN 1 END) as desa
		`)
	
	if user.Role != "admin" && user.Role != "1" && user.Role != "Admin" && user.IDTugas != "" {
		bpsWilayah := resolveTingkatToWilayah(user.IDTugas)
		if bpsWilayah != "" {
			masterQuery = masterQuery.Where("id_wilayah LIKE ?", bpsWilayah+"%")
		}
	}

	masterQuery.Scan(&master)

	var isi struct {
		Kab  int64
		Kec  int64
		Desa int64
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": gin.H{"total_empty_polres": master.Kab - isi.Kab, "details": gin.H{"polsek": master.Kec - isi.Kec, "kab_kota": master.Kab - isi.Kab, "kecamatan": master.Kec - isi.Kec, "kel_desa": master.Desa - isi.Desa}}})
}

func ValidatePotensiLahan(c *gin.Context) {
	var body struct {
		IDLahan int `json:"id_lahan"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Format request tidak valid"})
		return
	}

	var validatorID int

	if val, exists := c.Get("user"); exists {
		if user, ok := val.(models.User); ok {
			validatorID = int(user.ID)
		} else {
			if id, ok := val.(int); ok {
				validatorID = id
			}
		}
	}

	if validatorID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{
			"status":  "error",
			"message": "Gagal membaca ID User dari objek user. Cek tipe data struct User.",
		})
		return
	}

	var currentStatus string
	err := initializers.DB.Table("lahan").Where("id_lahan = ?", body.IDLahan).Select("status_lahan").Row().Scan(&currentStatus)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Data lahan tidak ditemukan"})
		return
	}

	updates := map[string]interface{}{}
	if currentStatus == "2" {
		updates["valid_oleh"] = nil
		updates["tgl_valid"] = nil
		updates["status_lahan"] = "1"
	} else {
		updates["valid_oleh"] = validatorID
		updates["tgl_valid"] = time.Now().Format("2006-01-02 15:04:05")
		updates["status_lahan"] = "2"
	}

	result := initializers.DB.Debug().Table("lahan").Where("id_lahan = ?", body.IDLahan).Updates(updates)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Gagal update database"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "Status validasi berhasil diperbarui",
	})
}

func UnvalidatePotensiLahan(c *gin.Context) {
	id := c.Param("id")
	updates := map[string]interface{}{"valid_oleh": nil, "tgl_valid": nil, "status_lahan": "1"}
	initializers.DB.Table("lahan").Where("id_lahan = ?", id).Select("valid_oleh", "tgl_valid", "status_lahan").Updates(updates)
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Validasi berhasil dibatalkan"})
}
