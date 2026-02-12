package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

// GetWilayah mengambil data hirarki wilayah (Kab, Kec, Desa)
func GetWilayah(c *gin.Context) {
	// Inisialisasi slice kosong agar jika tidak ada data, return-nya "[]" (bukan null)
	results := []models.WilayahResponse{}

	// Query SQL Self-Join
	// Menggabungkan tabel wilayah dengan dirinya sendiri untuk mendapat nama Kab & Kec
	query := `
		SELECT 
			d.kode,
			COALESCE(k.nama, '') AS kabupaten,
			COALESCE(c.nama, '') AS kecamatan,
			d.nama AS nama_desa,
			COALESCE(d.lat, 0) AS latitude,
			COALESCE(d.lng, 0) AS longitude,
			COALESCE(d.idanggota, '') AS updated_by,
			COALESCE(DATE_FORMAT(d.datetransaction, '%Y-%m-%d %H:%i:%s'), '') AS last_updated
		FROM wilayah d
		LEFT JOIN wilayah c ON c.kode = LEFT(d.kode, 8) 
		LEFT JOIN wilayah k ON k.kode = LEFT(d.kode, 5) 
		WHERE CHAR_LENGTH(d.kode) > 8 
		ORDER BY d.kode ASC
	`

	// Eksekusi Raw SQL
	if err := initializers.DB.Raw(query).Scan(&results).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Gagal mengambil data wilayah: " + err.Error(),
		})
		return
	}

	// --- PERBAIKAN DI SINI ---
	// Kita kembalikan Status 200 OK dan list kosong jika tidak ada data.
	// Jangan return 404, karena itu akan dianggap error oleh Flutter.
	c.JSON(http.StatusOK, results)
}

// CreateWilayah (Placeholder untuk route POST)
func CreateWilayah(c *gin.Context) {
	// Di sini nanti logika untuk menambah data wilayah
	// Sementara return sukses dulu agar tidak error 404
	c.JSON(http.StatusOK, gin.H{
		"message": "Fitur Create Wilayah belum diimplementasi (Placeholder)",
	})
}
func UpdateWilayah(c *gin.Context) {
	// Ambil Kode Desa dari URL (misal: /api/wilayah/35.01.01.2001)
	kode := c.Param("id")

	// Struktur input dari Flutter
	var body struct {
		Latitude  float64 `json:"latitude"`
		Longitude float64 `json:"longitude"`
	}

	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data tidak valid"})
		return
	}

	// Ambil User yang login untuk mengisi 'updated_by' (idanggota)
	userValue, _ := c.Get("user")
	currentUser := userValue.(models.User)

	// Update Database (Gunakan Raw SQL atau GORM Map agar aman dengan nama kolom custom)
	// Kita update lat, lng, idanggota (updated_by), dan datetransaction
	result := initializers.DB.Table("wilayah").
		Where("kode = ?", kode).
		Updates(map[string]interface{}{
			"lat":             body.Latitude,
			"lng":             body.Longitude,
			"idanggota":       currentUser.ID, // Siapa yang update
			"datetransaction": time.Now(),     // Kapan diupdate
		})

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal update data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Data berhasil diperbarui"})
}
