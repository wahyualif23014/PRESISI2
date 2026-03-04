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

	if err := db.Order("lahan.tgledit DESC").Limit(limit).Offset(offset).Find(&daftarLahan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success", "data": daftarLahan})

}

func ToggleValidation(c *gin.Context) {
	// 1. Ambil ID Lahan dari Body JSON (bukan dari URL)
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

	// 2. Ambil Validator ID dari Middleware JWT
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

	// 3. Cek Status Lahan Saat Ini
	var currentStatus string
	err := initializers.DB.Table("lahan").Where("idlahan = ?", body.IDLahan).Select("statuslahan").Row().Scan(&currentStatus)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"status": "error", "message": "Data lahan tidak ditemukan di database"})
		return
	}

	// 4. Siapkan Data Update Berdasarkan Status Saat Ini
	updates := map[string]interface{}{}

	if currentStatus == "2" {
		// Jika sudah validasi, batalkan validasi (kembali ke 1)
		updates["validoleh"] = 0 // Sesuaikan dengan standar kolom database milikmu (0 atau nil)
		updates["tglvalid"] = nil
		updates["statuslahan"] = "1"
	} else {
		// Jika belum validasi, lakukan validasi (ubah ke 2)
		updates["validoleh"] = validatorID
		updates["tglvalid"] = time.Now().Format("2006-01-02 15:04:05")
		updates["statuslahan"] = "2"
	}

	// 5. Eksekusi Update dan Tangani Error Database
	result := initializers.DB.Table("lahan").Where("idlahan = ?", body.IDLahan).Updates(updates)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"status": "error", "message": "Gagal menyimpan ke database: " + result.Error.Error()})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Data tidak berhasil diubah"})
		return
	}

	// 6. Balas Sukses
	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "Status validasi berhasil diperbarui",
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

	c.JSON(http.StatusOK, gin.H{
		"status": "success",
		"data": gin.H{
			"polres":      listPolres,
			"polsek":      listPolsek,
			"jenis_lahan": listJenis,
		},
	})

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

	dbFilter := "idjenislahan IS NOT NULL AND statuslahan = '1'"

	initializers.DB.Table("lahan").
		Where(dbFilter).
		Select("COALESCE(SUM(luaslahan),0) as total_area, COUNT(DISTINCT idjenislahan) as total_loc").
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
	var body struct {
		IDLahan int `json:"id_lahan"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"status": "error", "message": "Format request tidak valid"})
		return
	}

	var validatorID int

	// Mengambil data user dari context Gin
	if val, exists := c.Get("user"); exists {
		// Karena val berisi objek, kita coba akses field ID-nya.
		// Sesuaikan nama field 'ID' atau 'Idanggota' dengan struct models.User milikmu.
		// Berdasarkan log: 3283 adalah ID user kamu.

		// Kita gunakan pendekatan interface untuk mengambil ID dari struct
		if user, ok := val.(models.User); ok {
			validatorID = int(user.ID) // Atau user.Idanggota sesuai modelmu
		} else {
			// Jika casting struct gagal, kita coba cara alternatif (map atau manual)
			fmt.Printf("Data user ditemukan tapi tipe data berbeda: %T\n", val)

			// Berdasarkan logmu, ID ada di posisi pertama (3283).
			// Kita coba paksa ambil ID-nya jika middleware menyimpan sebagai ID langsung
			if id, ok := val.(int); ok {
				validatorID = id
			}
		}
	}

	// Jika validatorID masih 0, kita coba ambil 3283 secara manual dari log untuk tes sementara
	// Tapi sebaiknya pastikan casting model.User di atas sudah benar.
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

	// Debug untuk melihat query asli di terminal
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
