package controllers

import (
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

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	offset := (page - 1) * limit

	search := c.Query("search")
	polres := c.Query("polres")
	polsek := c.Query("polsek")
	jenisLahan := c.Query("jenis_lahan")
	statusVal := c.Query("status")

	db := initializers.DB.Table("lahan").
		Select("lahan.*, w_desa.nama AS nama_desa, w_kec.nama AS nama_kecamatan, w_kab.nama AS nama_kabupaten, p.nama AS nama_pemroses, v.nama AS nama_validator, akt.nama AS nama_poktan_asli, k.jeniskomoditi AS jenis_komoditas_nama, k.namakomoditi AS nama_komoditi_asli").
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
		db = db.Where("(LOWER(lahan.alamat) LIKE ? OR LOWER(lahan.ketcp) LIKE ?)", s, s)
	}

	if polres != "" {
		p := strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(polres), "POLRES", ""))
		db = db.Where("UPPER(w_kab.nama) LIKE ?", "%"+p+"%")
	}

	if polsek != "" {
		ps := strings.TrimSpace(strings.ReplaceAll(strings.ToUpper(polsek), "POLSEK", ""))
		db = db.Where("UPPER(w_kec.nama) LIKE ?", "%"+ps+"%")
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
		case "HUTAN (PERHUTANI/INHUTANI)":
			idJenis = 8
		case "LAHAN LAINNYA":
			idJenis = 9
		}
		if idJenis > 0 {
			db = db.Where("lahan.idjenislahan = ?", idJenis)
		}
	}

	if statusVal != "" {
		if statusVal == "Sudah Divalidasi" {
			db = db.Where("lahan.validoleh IS NOT NULL AND lahan.validoleh != '' AND lahan.validoleh != '0'")
		} else if statusVal == "Belum Divalidasi" {
			db = db.Where("(lahan.validoleh IS NULL OR lahan.validoleh = '' OR lahan.validoleh = '0')")
		}
	}

	if err := db.Order("lahan.tgledit DESC").Limit(limit).Offset(offset).Find(&daftarLahan).Error; err != nil {
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
	err := initializers.DB.Table("lahan").Where("idlahan = ?", body.IDLahan).Select("statuslahan").Row().Scan(&currentStatus)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Data lahan tidak ditemukan di database"})
		return
	}

	updates := map[string]interface{}{}

	if currentStatus == "2" {
		updates["validoleh"] = 0
		updates["tglvalid"] = nil
		updates["statuslahan"] = "1"
	} else {
		updates["validoleh"] = validatorID
		updates["tglvalid"] = time.Now().Format("2006-01-02 15:04:05")
		updates["statuslahan"] = "2"
	}

	result := initializers.DB.Table("lahan").Where("idlahan = ?", body.IDLahan).Updates(updates)

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

func GetFilterOptions(c *gin.Context) {
	polresParam := c.Query("polres")
	polsekParam := c.Query("polsek")

	type WilayahData struct {
		Nama string `json:"nama"`
		Kode string `json:"kode"`
	}

	var rawPolres []WilayahData
	initializers.DB.Table("wilayah").
		Select("nama, kode").
		Where("CHAR_LENGTH(kode) = 5").
		Order("nama ASC").
		Scan(&rawPolres)

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
			Select("kode").
			Where("CHAR_LENGTH(kode) = 5 AND UPPER(nama) LIKE ?", "%"+dbParam+"%").
			Limit(1).
			Pluck("kode", &kabKode)
	}

	if kabKode != "" {
		var rawPolsek []WilayahData
		initializers.DB.Table("wilayah").
			Select("nama, kode").
			Where("CHAR_LENGTH(kode) = 8 AND kode LIKE ?", kabKode+".%").
			Order("nama ASC").
			Scan(&rawPolsek)

		for _, v := range rawPolsek {
			listPolsek = append(listPolsek, map[string]interface{}{
				"nama": fmt.Sprintf("POLSEK %s", strings.ToUpper(v.Nama)),
				"kode": v.Kode,
			})
		}
	}

	var kecKode string
	if polsekParam != "" && kabKode != "" {
		dbParam := strings.ToUpper(polsekParam)
		dbParam = strings.ReplaceAll(dbParam, "POLSEK", "")
		dbParam = strings.TrimSpace(dbParam)

		initializers.DB.Table("wilayah").
			Select("kode").
			Where("CHAR_LENGTH(kode) = 8 AND kode LIKE ? AND UPPER(nama) LIKE ?", kabKode+".%", "%"+dbParam+"%").
			Limit(1).
			Pluck("kode", &kecKode)
	}

	if kecKode != "" {
		var rawDesa []WilayahData
		initializers.DB.Table("wilayah").
			Select("nama, kode").
			Where("CHAR_LENGTH(kode) > 8 AND kode LIKE ?", kecKode+".%").
			Order("nama ASC").
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
		Select("idkomoditi AS id, jeniskomoditi AS jenis, namakomoditi AS nama").
		Order("jeniskomoditi ASC, namakomoditi ASC").
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

	// Perbaikan Error 1364: idanggota otomatis diisi dengan ID user (EditOleh)
	input.IDAnggota = input.EditOleh
	if input.IDAnggota == "" {
		input.IDAnggota = "0"
	}

	db := initializers.DB.Table("lahan")

	var omitFields []string
	if input.TglValid == "" || input.TglValid == "-" {
		omitFields = append(omitFields, "tglvalid")
	}
	if input.ValidOleh == "" || input.ValidOleh == "0" || input.ValidOleh == "-" {
		omitFields = append(omitFields, "validoleh")
	}

	if len(omitFields) > 0 {
		db = db.Omit(omitFields...)
	}

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

	// Sinkronisasi idanggota dengan editoleh saat update
	idAnggota := input.EditOleh
	if idAnggota == "" {
		idAnggota = "0"
	}

	updates := map[string]interface{}{
		"idwilayah":    input.IDWilayah,
		"idjenislahan": input.IDJenisLahan,
		"idkomoditi":   input.IDKomoditi,
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
		"tgledit":      time.Now().Format("2006-01-02 15:04:05"),
		"editoleh":     input.EditOleh,
		"idanggota":    idAnggota,
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

	dbFilter := `
		deletestatus = '2'
		AND statuslahan = '1'
		AND idjenislahan IS NOT NULL
	`

	initializers.DB.Table("lahan").
		Where(dbFilter).
		Select(`
			COALESCE(SUM(luaslahan),0) as total_area,
			COUNT(idlahan) as total_loc
		`).
		Scan(&totals)

	var categories []SummaryCategory

	rows, err := initializers.DB.Table("lahan").
		Where(dbFilter).
		Select(`
			idjenislahan,
			COALESCE(SUM(luaslahan),0) as area,
			COUNT(idlahan) as count
		`).
		Group("idjenislahan").
		Order("idjenislahan ASC").
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
				title = "HUTAN (PERHUTANI/INHUTANI)"
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

	var master struct {
		Kab  int64
		Kec  int64
		Desa int64
	}

	// Hitung total wilayah master
	initializers.DB.Table("wilayah").
		Select(`
			COUNT(CASE WHEN LENGTH(kode) = 5 THEN 1 END) as kab,
			COUNT(CASE WHEN LENGTH(kode) = 8 THEN 1 END) as kec,
			COUNT(CASE WHEN LENGTH(kode) > 8 THEN 1 END) as desa
		`).
		Scan(&master)

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
	err := initializers.DB.Table("lahan").Where("idlahan = ?", body.IDLahan).Select("statuslahan").Row().Scan(&currentStatus)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Data lahan tidak ditemukan"})
		return
	}

	updates := map[string]interface{}{}
	if currentStatus == "2" {
		updates["validoleh"] = nil
		updates["tglvalid"] = nil
		updates["statuslahan"] = "1"
	} else {
		updates["validoleh"] = validatorID
		updates["tglvalid"] = time.Now().Format("2006-01-02 15:04:05")
		updates["statuslahan"] = "2"
	}

	result := initializers.DB.Debug().Table("lahan").Where("idlahan = ?", body.IDLahan).Updates(updates)

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
	updates := map[string]interface{}{"validoleh": nil, "tglvalid": nil, "statuslahan": "1"}
	initializers.DB.Table("lahan").Where("idlahan = ?", id).Select("validoleh", "tglvalid", "statuslahan").Updates(updates)
	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Validasi berhasil dibatalkan"})
}
