package controllers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

// --- DTO (Data Transfer Object) ---
type JabatanInput struct {
	NamaJabatan string `json:"nama_jabatan" binding:"required"`
}

// 1. GET ALL JABATAN (Untuk Dropdown Menu)
func GetJabatan(c *gin.Context) {
	var jabatan []models.Jabatan

	result := initializers.DB.
		Where("deletestatus = ?", "2").
		Find(&jabatan)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data jabatan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": jabatan})
}

// 2. CREATE JABATAN (Tambah Jabatan Baru)
func CreateJabatan(c *gin.Context) {
	var body JabatanInput

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input harus berisi nama_jabatan"})
		return
	}

	// Siapkan data model
	jabatan := models.Jabatan{
		NamaJabatan:     body.NamaJabatan,
		DeleteStatus:    "2", // Default Aktif
		DateTransaction: time.Now(),
		// IDAnggota bisa diisi dari token user yang login jika perlu (middleware)
	}

	// Simpan ke DB
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

	// Validasi Input
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input salah"})
		return
	}

	// Cari Data & Update
	var jabatan models.Jabatan
	if err := initializers.DB.First(&jabatan, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Jabatan tidak ditemukan"})
		return
	}

	// Update Nama
	initializers.DB.Model(&jabatan).Update("namajabatan", body.NamaJabatan)

	c.JSON(http.StatusOK, gin.H{"message": "Jabatan berhasil diupdate", "data": jabatan})
}

// 4. DELETE JABATAN (Soft Delete)
func DeleteJabatan(c *gin.Context) {
	id := c.Param("id")

	// Ubah deletestatus jadi '1' (Deleted)
	result := initializers.DB.Model(&models.Jabatan{}).
		Where("idjabatan = ?", id).
		Update("deletestatus", "1")

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus jabatan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Jabatan berhasil dihapus"})
}