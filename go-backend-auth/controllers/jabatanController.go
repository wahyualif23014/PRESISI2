package controllers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

// --- DTO ---
type JabatanInput struct {
	NamaJabatan string `json:"nama_jabatan" binding:"required"`
}

// 1. GET JABATAN (Hanya yang Aktif)
func GetJabatan(c *gin.Context) {
	var jabatan []models.Jabatan

	// Filter deletestatus = '2' (Aktif)
	result := initializers.DB.Where("deletestatus = ?", "2").Find(&jabatan)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data jabatan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": jabatan})
}

// 2. CREATE JABATAN
func CreateJabatan(c *gin.Context) {
	var body JabatanInput

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input harus berisi nama_jabatan"})
		return
	}
	var idPembuat uint64 = 0
	if user, exists := c.Get("user"); exists {
		if u, ok := user.(models.User); ok {
			idPembuat = u.ID
		}
	}

	jabatan := models.Jabatan{
		NamaJabatan:     body.NamaJabatan,
		DeleteStatus:    "2", 
		DateTransaction: time.Now(),
		IDAnggota:       &idPembuat, // Simpan ID User (Pointer)
	}

	result := initializers.DB.Create(&jabatan)
	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan jabatan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Jabatan berhasil ditambahkan",
		"data":    jabatan,
	})
}

// 3. UPDATE JABATAN
func UpdateJabatan(c *gin.Context) {
	id := c.Param("id")
	var body JabatanInput

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input salah"})
		return
	}

	var jabatan models.Jabatan
	
	if err := initializers.DB.Where("idjabatan = ? AND deletestatus = ?", id, "2").First(&jabatan).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Jabatan tidak ditemukan atau sudah dihapus"})
		return
	}

	// Update Data
	initializers.DB.Model(&jabatan).Updates(models.Jabatan{
		NamaJabatan: body.NamaJabatan,
		DateTransaction: time.Now(), 
	})

	c.JSON(http.StatusOK, gin.H{"message": "Jabatan berhasil diupdate", "data": jabatan})
}

// 4. DELETE JABATAN (Soft Delete)
func DeleteJabatan(c *gin.Context) {
	id := c.Param("id")

	// Ubah deletestatus jadi '1'
	result := initializers.DB.Model(&models.Jabatan{}).
		Where("idjabatan = ? AND deletestatus = ?", id, "2"). // Pastikan hanya hapus yg statusnya '2'
		Update("deletestatus", "1")

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus jabatan"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data tidak ditemukan atau sudah terhapus"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Jabatan berhasil dihapus"})
}