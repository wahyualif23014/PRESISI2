// controllers/wilayahController.go
package controllers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

func GetWilayah(c *gin.Context) {
	results := []models.WilayahResponse{}
	query := `
		SELECT 
			d.id_wilayah AS kode,
			COALESCE(k.nama_wilayah, '') AS kabupaten,
			COALESCE(c.nama_wilayah, '') AS kecamatan,
			d.nama_wilayah AS nama_desa,
			COALESCE(d.Latitude, 0) AS latitude,
			COALESCE(d.longitude, 0) AS longitude,
			COALESCE(d.id_anggota, '') AS updated_by,
			COALESCE(DATE_FORMAT(d.datetransaction, '%Y-%m-%d %H:%i:%s'), '') AS last_updated
		FROM wilayah d
		LEFT JOIN wilayah c ON c.id_wilayah = LEFT(d.id_wilayah, 8) 
		LEFT JOIN wilayah k ON k.id_wilayah = LEFT(d.id_wilayah, 5) 
		WHERE CHAR_LENGTH(d.id_wilayah) > 8 
		ORDER BY d.id_wilayah ASC
	`
	if err := initializers.DB.Raw(query).Scan(&results).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, results)
}

func UpdateWilayah(c *gin.Context) {
	kode := c.Param("id")
	var body struct {
		Latitude  float64 `json:"latitude"`
		Longitude float64 `json:"longitude"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data tidak valid"})
		return
	}

	// Ambil user dari middleware JWT
	userValue, _ := c.Get("user")
	currentUser := userValue.(models.User)

	result := initializers.DB.Table("wilayah").
		Where("id_wilayah = ?", kode).
		Updates(map[string]interface{}{
			"Latitude":        body.Latitude,
			"longitude":       body.Longitude,
			"id_anggota":      currentUser.ID,
			"datetransaction": time.Now(),
		})

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal update"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Berhasil diperbarui"})
}
