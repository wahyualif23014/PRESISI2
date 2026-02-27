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

// ==================== IMAGE HANDLING ====================

func GetImageFromDB(c *gin.Context) {
	filenameRaw := c.Param("filename")
	filename, err := url.QueryUnescape(filenameRaw)
	if err != nil {
		filename = filenameRaw
	}

	var lahan models.PotensiLahan
	result := initializers.DB.Table("lahan").Where("dokumentasi = ?", filename).First(&lahan)

	if result.Error != nil {
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
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Base64 Rusak"})
			return
		}
	}

	c.Data(http.StatusOK, "image/jpeg", imageBytes)
}

// ==================== READ OPERATIONS ====================

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
			lahan.idlahan, lahan.idtingkat, lahan.idwilayah, lahan.idjenislahan, lahan.alamat, 
			lahan.longi, lahan.lat, lahan.poktan, lahan.cp, lahan.hp, lahan.luaslahan, 
			lahan.ketlahan, lahan.sk, lahan.lembaga, lahan.cppolisi, lahan.hppolisi, 
			lahan.keterangan, lahan.sumberdata, lahan.dokumentasi, lahan.jmlsantri, 
			lahan.datetransaction, lahan.statuslahan, lahan.idkomoditi, 
			lahan.editoleh, lahan.tgledit, lahan.validoleh, lahan.tglvalid,
			lahan.statuspakai, lahan.statusaktif, lahan.tahunlahan, lahan.suratedit, lahan.deletestatus, lahan.conlahan, lahan.ketcp,
			MAX(w_desa.nama) AS nama_desa, 
			MAX(w_kec.nama) AS nama_kecamatan, 
			MAX(w_kab.nama) AS nama_kabupaten,
			MAX(p.nama) AS nama_pemroses,
			MAX(v.nama) AS nama_validator,
			MAX(k.jeniskomoditi) AS jenis_komoditas_nama,
			MAX(k.namakomoditi) AS nama_komoditi_asli
		`).
		Joins("LEFT JOIN wilayah w_desa ON w_desa.kode = lahan.idwilayah").
		Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = SUBSTR(lahan.idwilayah, 1, 8)").
		Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah, 1, 5)").
		Joins("LEFT JOIN anggota p ON p.idanggota = lahan.editoleh").
		Joins("LEFT JOIN anggota v ON v.idanggota = lahan.validoleh").
		Joins("LEFT JOIN komoditi k ON k.idkomoditi = lahan.idkomoditi").
		Where("lahan.statuslahan IN ('1', '2', '3', '4') AND lahan.deletestatus = '1'") // Menyesuaikan filter aktif

	if search != "" {
		s := "%" + strings.ToLower(search) + "%"
		db = db.Where("LOWER(lahan.alamat) LIKE ? OR LOWER(lahan.keterangan) LIKE ?", s, s)
	}

	if polres != "" {
		pName := strings.ReplaceAll(strings.ToUpper(polres), "POLRES ", "")
		db = db.Where("UPPER(w_kab.nama) LIKE ?", "%"+pName+"%")
	}
	if polsek != "" {
		sName := strings.ReplaceAll(strings.ToUpper(polsek), "POLSEK ", "")
		db = db.Where("UPPER(w_kec.nama) LIKE ?", "%"+sName+"%")
	}

	if err := db.Group("lahan.idlahan").Order("lahan.datetransaction DESC").Limit(limit).Offset(offset).Find(&daftarLahan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	baseURL := "http://192.168.100.196:8080/api/potensi-lahan/image/"
	for i := range daftarLahan {
		if daftarLahan[i].Foto != "" {
			daftarLahan[i].ImageURL = baseURL + url.QueryEscape(daftarLahan[i].Foto)
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data":   daftarLahan,
	})
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
		listPolres = append(listPolres, fmt.Sprintf("POLRES %s", strings.TrimSpace(name)))
	}

	queryPolsek := initializers.DB.Table("lahan").
		Select("DISTINCT w_kec.nama").
		Joins("LEFT JOIN wilayah w_kec ON w_kec.kode = SUBSTR(lahan.idwilayah, 1, 8)").
		Where("w_kec.nama IS NOT NULL")

	if polresParam != "" {
		dbParam := strings.ReplaceAll(strings.ToUpper(polresParam), "POLRES", "")
		queryPolsek = queryPolsek.
			Joins("LEFT JOIN wilayah w_kab ON w_kab.kode = SUBSTR(lahan.idwilayah, 1, 5)").
			Where("UPPER(w_kab.nama) LIKE ?", "%"+strings.TrimSpace(dbParam)+"%")
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
				title = "MILIK POLRI"
			case 2:
				title = "POKTAN BINAAN POLRI"
			case 3:
				title = "MASYARAKAT BINAAN POLRI"
			case 4:
				title = "TUMPANG SARI"
			case 5:
				title = "PERHUTANAN SOSIAL"
			case 6:
				title = "LBS"
			case 7:
				title = "PESANTREN"
			}
			listJenis = append(listJenis, title)
		}
	}

	c.JSON(200, gin.H{
		"status": "success",
		"data": gin.H{
			"polres":      listPolres,
			"polsek":      listPolsek,
			"jenis_lahan": listJenis,
		},
	})
}

// ==================== WRITE OPERATIONS ====================

func CreatePotensiLahan(c *gin.Context) {
	var input models.PotensiLahan

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Data tidak valid: " + err.Error()})
		return
	}

	userValue, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Sesi login tidak ditemukan"})
		return
	}
	user := userValue.(models.User)

	// Audit Trail & Default Values sesuai Skema DB
	input.IDAnggota = user.ID
	input.IDTingkat = user.IDTugas
	input.DateTransaction = time.Now()

	// SINKRONISASI ENUM AGAR TIDAK ERROR 1265
	input.DeleteStatus = "1" // Default Aktif (enum '1','2')

	if input.StatusPakai == "" {
		input.StatusPakai = "1" // Default enum '1'
	}
	if input.StatusAktif == "" {
		input.StatusAktif = "2" // Default enum '2'
	}
	if input.KetLahan == "" {
		input.KetLahan = "3" // Default enum '3'
	}
	if input.StatusLahan == "" || input.StatusLahan == "BELUM TERVALIDASI" {
		input.StatusLahan = "1" // Default enum '1'
	}

	// Lookup ID Wilayah
	var idWilayah string
	initializers.DB.Table("tingkatwilayah").
		Select("idwilayah").
		Where("idtingkat = ?", user.IDTugas).
		Limit(1).
		Scan(&idWilayah)

	if idWilayah == "" {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Mapping wilayah tidak ditemukan."})
		return
	}
	input.IDWilayah = idWilayah

	// Execute Create
	if err := initializers.DB.Table("lahan").Create(&input).Error; err != nil {
		fmt.Printf("CRITICAL DB ERROR: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Database Error: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"status": "success", "data": input})
}

func UpdatePotensiLahan(c *gin.Context) {
	id := c.Param("id")
	var lahan models.PotensiLahan

	if err := initializers.DB.Table("lahan").Where("idlahan = ?", id).First(&lahan).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Data tidak ditemukan"})
		return
	}

	var input models.PotensiLahan
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Format data salah: " + err.Error()})
		return
	}

	// Audit Trail Edit
	userValue, _ := c.Get("user")
	user := userValue.(models.User)
	input.EditOleh = user.ID
	now := time.Now()
	input.TglEdit = &now

	// ENUM Guards untuk Update agar konsisten dengan skema
	if input.StatusPakai != "" && input.StatusPakai != "1" && input.StatusPakai != "2" {
		input.StatusPakai = "1"
	}
	if input.StatusAktif != "" && input.StatusAktif != "1" && input.StatusAktif != "2" {
		input.StatusAktif = "2"
	}

	if err := initializers.DB.Table("lahan").Where("idlahan = ?", id).Updates(&input).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Update Gagal: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": input})
}

func DeletePotensiLahan(c *gin.Context) {
	id := c.Param("id")
	// Soft Delete menggunakan ENUM '2' sesuai skema DB
	result := initializers.DB.Table("lahan").Where("idlahan = ?", id).Update("deletestatus", "2")

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": result.Error.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "message": "Data berhasil dihapus secara logis"})
}


// ==================== SUMMARY & ANALYTICS ====================

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

	// SINKRONISASI FILTER: Menambahkan 'statuslahan' agar angka di dashboard
	dbFilter := "idwilayah IS NOT NULL AND deletestatus = '2' AND statuslahan IN ('1', '2', '3', '4')"

	// 1. Ambil Total Keseluruhan (Area & Lokasi)
	initializers.DB.Table("lahan").
		Where(dbFilter).
		Select("COALESCE(SUM(luaslahan), 0) as total_area, COUNT(DISTINCT idlahan) as total_loc").
		Scan(&totals)

	// 2. Ambil Rincian per Kategori
	var categories []SummaryCategory
	rows, err := initializers.DB.Table("lahan").
		Where(dbFilter).
		Select("idjenislahan, COALESCE(SUM(luaslahan), 0) as area, COUNT(DISTINCT idlahan) as count").
		Group("idjenislahan").
		Rows()

	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var id int
			var area float64
			var count int64
			rows.Scan(&id, &area, &count)

			title := "LAINNYA"
			switch id {
			case 1:
				title = "POKTAN BINAAN POLRI"
			case 2:
				title = "PERHUTANAN SOSIAL"
			case 3:
				title = "LBS"
			case 4:
				title = "PESANTREN"
			case 5:
				title = "MILIK POLRI"
			case 6:
				title = "MASYARAKAT BINAAN POLRI"
			case 7:
				title = "TUMPANGSARI"
			case 8:
				title = "PERHUTANI/INHUTANI"

			}
			categories = append(categories, SummaryCategory{
				Title: title,
				Area:  area,
				Count: count,
			})
		}
	}

	// 3. Kirim Response JSON yang Sinkron dengan LandSummaryWidget
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
	var master struct{ Kab, Kec, Desa int64 }
	initializers.DB.Table("wilayah").
		Select("SUM(CASE WHEN CHAR_LENGTH(kode) = 5 THEN 1 ELSE 0 END) as kab, SUM(CASE WHEN CHAR_LENGTH(kode) = 8 THEN 1 ELSE 0 END) as kec, SUM(CASE WHEN CHAR_LENGTH(kode) > 8 THEN 1 ELSE 0 END) as desa").
		Scan(&master)

	var isi struct{ Kab, Kec, Desa int64 }
	dbFilter := "idwilayah IS NOT NULL AND deletestatus = '2' AND statuslahan IN ('1', '2', '3', '4')"

	initializers.DB.Table("lahan").
		Where(dbFilter).
		Select("COUNT(DISTINCT SUBSTR(idwilayah, 1, 5)) as kab, COUNT(DISTINCT SUBSTR(idwilayah, 1, 8)) as kec, COUNT(DISTINCT idwilayah) as desa").
		Scan(&isi)

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data": gin.H{
			// Menampilkan jumlah yang sudah terisi (seperti di tampilan Web bagian bawah)
			"total_locations": isi.Desa,
			"details": gin.H{
				"polres":    isi.Kab,
				"polsek":    isi.Kec,
				"kab_kota":  isi.Kab,
				"kecamatan": isi.Kec,
				"kel_desa":  isi.Desa,
			},
		},
	})
}
