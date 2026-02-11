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
	NamaJabatan string  `json:"nama_jabatan" binding:"required"`
	IDAnggota   *uint64 `json:"id_anggota"` // Pointer agar bisa null
}

// --- HELPER ---
func mapToResponse(j models.Jabatan) models.JabatanResponse {
	namaPejabat := "-"
	nrp := "-"

	if j.AnggotaDetail != nil {
		namaPejabat = j.AnggotaDetail.NamaLengkap
		nrp = j.AnggotaDetail.NRP
	}

	return models.JabatanResponse{
		ID:               j.ID,
		NamaJabatan:      j.NamaJabatan,
		NamaPejabat:      namaPejabat,
		NRP:              nrp,
		TanggalPeresmian: j.DateTransaction.Format("2006-01-02"),
	}
}

// 1. GET ALL
func GetJabatan(c *gin.Context) {
	var jabatans []models.Jabatan

	// Preload Relasi Anggota
	result := initializers.DB.
		Preload("AnggotaDetail").
		Where("deletestatus = ?", "2").
		Find(&jabatans)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data"})
		return
	}

	// Mapping Response
	var response []models.JabatanResponse
	for _, j := range jabatans {
		response = append(response, mapToResponse(j))
	}

	c.JSON(http.StatusOK, gin.H{"data": response})
}

// 2. CREATE
func CreateJabatan(c *gin.Context) {
	var input JabatanInput

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	jabatan := models.Jabatan{
		NamaJabatan:     input.NamaJabatan,
		IDAnggota:       input.IDAnggota,
		DeleteStatus:    "2",
		DateTransaction: time.Now(),
	}

	if err := initializers.DB.Create(&jabatan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data"})
		return
	}

	// Load ulang untuk dapat nama anggota
	initializers.DB.Preload("AnggotaDetail").First(&jabatan, jabatan.ID)

	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil ditambahkan",
		"data":    mapToResponse(jabatan),
	})
}

// 3. UPDATE
func UpdateJabatan(c *gin.Context) {
	id := c.Param("id")
	var input JabatanInput

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var jabatan models.Jabatan
	if err := initializers.DB.Where("idjabatan = ? AND deletestatus = ?", id, "2").First(&jabatan).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data tidak ditemukan"})
		return
	}

	// Update Field
	jabatan.NamaJabatan = input.NamaJabatan
	jabatan.IDAnggota = input.IDAnggota

	if err := initializers.DB.Save(&jabatan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal update data"})
		return
	}

	initializers.DB.Preload("AnggotaDetail").First(&jabatan, jabatan.ID)

	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil diupdate",
		"data":    mapToResponse(jabatan),
	})
}

// 4. DELETE
func DeleteJabatan(c *gin.Context) {
	id := c.Param("id")

	result := initializers.DB.Model(&models.Jabatan{}).
		Where("idjabatan = ? AND deletestatus = ?", id, "2").
		Update("deletestatus", "1")

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus data"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Data tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Data berhasil dihapus"})
}