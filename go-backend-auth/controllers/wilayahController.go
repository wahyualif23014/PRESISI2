package controllers

import (
	"net/http"
	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

// CreateWilayah godoc
// @Summary      Tambah Wilayah Baru
// @Description  Membuat data master wilayah (Kecamatan/Kabupaten)
// @Tags         Master Data (Wilayah)
// @Accept       json
// @Produce      json
// @Param        body body object{kabupaten=string,kecamatan=string,latitude=number,longitude=number} true "Data Wilayah"
// @Success      200 {object} map[string]interface{}
// @Failure      400 {object} map[string]interface{}
// @Router       /admin/wilayah [post]
// @Security     BearerAuth
func CreateWilayah(c *gin.Context) {
	var body struct {
		Kabupaten string
		Kecamatan string
		Latitude  float64
		Longitude float64
	}

	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal membaca body"})
		return
	}

	wilayah := models.Wilayah{
		Kabupaten: body.Kabupaten,
		Kecamatan: body.Kecamatan,
		Latitude:  body.Latitude,
		Longitude: body.Longitude,
	}

	result := initializers.DB.Create(&wilayah)

	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal membuat wilayah"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": wilayah})
}

// GetWilayah godoc
// @Summary      Lihat Semua Wilayah
// @Description  Mengambil list semua wilayah yang terdaftar
// @Tags         Master Data (Wilayah)
// @Produce      json
// @Success      200 {object} map[string]interface{}
// @Router       /admin/wilayah [get]
// @Security     BearerAuth
func GetWilayah(c *gin.Context) {
	var wilayah []models.Wilayah
	initializers.DB.Find(&wilayah)
	c.JSON(http.StatusOK, gin.H{"data": wilayah})
}