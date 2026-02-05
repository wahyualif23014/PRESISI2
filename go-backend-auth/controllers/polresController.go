package controllers

import (
	"net/http"
	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

// CreatePolres godoc
// @Summary      Tambah Polres Baru
// @Description  Membuat data Polres dengan referensi ID Wilayah
// @Tags         Master Data (Polres)
// @Accept       json
// @Produce      json
// @Param        body body object{nama_polres=string,kapolres=string,no_telp_polres=string,wilayah_id=int} true "Data Polres"
// @Success      200 {object} map[string]interface{}
// @Failure      400 {object} map[string]interface{}
// @Router       /admin/polres [post]
// @Security     BearerAuth
func CreatePolres(c *gin.Context) {
	var body struct {
		NamaPolres   string
		Kapolres     string
		NoTelpPolres string
		WilayahID    uint // Foreign Key
	}

	if c.Bind(&body) != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal membaca body"})
		return
	}

	polres := models.Polres{
		NamaPolres:   body.NamaPolres,
		Kapolres:     body.Kapolres,
		NoTelpPolres: body.NoTelpPolres,
		WilayahID:    body.WilayahID,
	}

	result := initializers.DB.Create(&polres)

	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal membuat polres. Pastikan ID Wilayah valid."})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": polres})
}

// GetPolres godoc
// @Summary      Lihat Semua Polres
// @Description  Mengambil list semua Polres beserta detail Wilayahnya
// @Tags         Master Data (Polres)
// @Produce      json
// @Success      200 {object} map[string]interface{}
// @Router       /admin/polres [get]
// @Security     BearerAuth
func GetPolres(c *gin.Context) {
	var polres []models.Polres
	// Preload("Wilayah") fungsinya seperti JOIN, agar data wilayah ikut muncul
	initializers.DB.Preload("Wilayah").Find(&polres)
	c.JSON(http.StatusOK, gin.H{"data": polres})
}