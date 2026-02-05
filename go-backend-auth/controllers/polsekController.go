package controllers

import (
	"net/http"
	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

// CreatePolsek godoc
// @Summary      Tambah Polsek Baru
// @Description  Membuat data Polsek dengan referensi ID Polres dan ID Wilayah
// @Tags         Master Data (Polsek)
// @Accept       json
// @Produce      json
// @Param        body body object{nama_polsek=string,kapolsek=string,no_telp_polsek=string,kode=string,polres_id=int,wilayah_id=int} true "Data Polsek"
// @Success      200 {object} map[string]interface{}
// @Failure      400 {object} map[string]interface{}
// @Router       /admin/polsek [post]
// @Security     BearerAuth
func CreatePolsek(c *gin.Context) {
	var body struct {
		NamaPolsek   string
		Kapolsek     string
		NoTelpPolsek string
		Kode         string
		PolresID     uint // Foreign Key
		WilayahID    uint // Foreign Key
	}

	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal membaca body"})
		return
	}

	polsek := models.Polsek{
		NamaPolsek:   body.NamaPolsek,
		Kapolsek:     body.Kapolsek,
		NoTelpPolsek: body.NoTelpPolsek,
		Kode:         body.Kode,
		PolresID:     body.PolresID,
		WilayahID:    body.WilayahID,
	}

	result := initializers.DB.Create(&polsek)

	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal membuat polsek. Cek ID Polres/Wilayah."})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": polsek})
}

// GetPolsek godoc
// @Summary      Lihat Semua Polsek
// @Description  Mengambil list semua Polsek beserta detail Polres dan Wilayahnya
// @Tags         Master Data (Polsek)
// @Produce      json
// @Success      200 {object} map[string]interface{}
// @Router       /admin/polsek [get]
// @Security     BearerAuth
func GetPolsek(c *gin.Context) {
	var polsek []models.Polsek
	// Preload relasi agar data induknya (Polres & Wilayah) ikut tampil
	initializers.DB.Preload("Polres").Preload("Wilayah").Find(&polsek)
	c.JSON(http.StatusOK, gin.H{"data": polsek})
}