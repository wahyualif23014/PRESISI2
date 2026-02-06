package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
	"golang.org/x/crypto/bcrypt"
)

// --- STRUCTS (DTO) ---
// Kita sesuaikan input JSON dengan field model baru

type CreateUserInput struct {
	NamaLengkap string `json:"nama_lengkap" binding:"required"`
	IDTugas     string `json:"id_tugas" binding:"required"`    
	Username    string `json:"username" binding:"required"`     
	JabatanID   uint64 `json:"id_jabatan" binding:"required"`   
	Password    string `json:"password" binding:"required"`
	Role        string `json:"role" binding:"required"`         // "1", "2", "3"
	NoTelp      string `json:"no_telp" binding:"required"`
}

type UpdateUserInput struct {
	NamaLengkap string  `json:"nama_lengkap" binding:"omitempty"`
	JabatanID   *uint64 `json:"id_jabatan" binding:"omitempty"`
	Role        string  `json:"role" binding:"omitempty"`
	NoTelp      string  `json:"no_telp" binding:"omitempty"`
}

// --- HANDLERS ---

// CreateUser (Admin Only)
func CreateUser(c *gin.Context) {
	var body CreateUserInput

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data salah: " + err.Error()})
		return
	}

	// Hash Password
	hash, err := bcrypt.GenerateFromPassword([]byte(body.Password), 10)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal hash password"})
		return
	}

	user := models.User{
		NamaLengkap:  body.NamaLengkap,
		IDTugas:      body.IDTugas,
		Username:     body.Username,
		JabatanID:    &body.JabatanID,
		KataSandi:    string(hash),
		Role:         body.Role,
		NoTelp:       body.NoTelp,
		DeleteStatus: models.StatusActive, // Default '2'
		IDPengguna:   1,                   // Default Admin ID
	}

	result := initializers.DB.Create(&user)
	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal simpan. ID Tugas/Username mungkin duplikat."})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User berhasil ditambahkan", "data": user})
}

// GetUsers - INI YANG BERFUNGSI MEMBACA DATA DI GAMBAR
func GetUsers(c *gin.Context) {
	var users []models.User


	result := initializers.DB.
		Select("idanggota", "nama", "idtugas", "username", "statusadmin", "idjabatan", "hp").
		Where("deletestatus = ?", models.StatusActive). // Hanya ambil yg aktif ('2')
		Find(&users)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data"})
		return
	}

	// Mapping result agar JSON response rapi
	var responseData []gin.H
	for _, u := range users {
		responseData = append(responseData, gin.H{
			"id":           u.ID,           // idanggota
			"nama_lengkap": u.NamaLengkap, // nama
			"id_tugas":     u.IDTugas,     // idtugas
			"username":     u.Username,    // username
			"role":         u.Role,        // statusadmin (1/2/3)
			"no_telp":      u.NoTelp,      // hp
			"id_jabatan":   u.JabatanID,   // idjabatan
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": responseData})
}

// GetUserByID
func GetUserByID(c *gin.Context) {
	id := c.Param("id")
	var user models.User

	result := initializers.DB.
		Select("idanggota", "nama", "idtugas", "username", "statusadmin", "idjabatan", "hp").
		Where("idanggota = ? AND deletestatus = ?", id, models.StatusActive).
		First(&user)

	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"id":           user.ID,
			"nama_lengkap": user.NamaLengkap,
			"id_tugas":     user.IDTugas,
			"username":     user.Username,
			"role":         user.Role,
			"no_telp":      user.NoTelp,
			"id_jabatan":   user.JabatanID,
		},
	})
}

// UpdateUser
func UpdateUser(c *gin.Context) {
	id := c.Param("id")
	var user models.User

	// Cek user exist
	if err := initializers.DB.Where("idanggota = ?", id).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	var body UpdateUserInput
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data salah"})
		return
	}

	// Update Map
	updates := make(map[string]interface{})
	if body.NamaLengkap != "" {
		updates["nama"] = body.NamaLengkap
	}
	if body.JabatanID != nil {
		updates["idjabatan"] = *body.JabatanID
	}
	if body.NoTelp != "" {
		updates["hp"] = body.NoTelp
	}
	if body.Role != "" {
		updates["statusadmin"] = body.Role
	}

	initializers.DB.Model(&user).Updates(updates)
	c.JSON(http.StatusOK, gin.H{"message": "Data berhasil diupdate"})
}

// DeleteUser (Soft Delete)
func DeleteUser(c *gin.Context) {
	id := c.Param("id")
	
	// Set deletestatus = '1'
	result := initializers.DB.Model(&models.User{}).
		Where("idanggota = ?", id).
		Update("deletestatus", models.StatusDeleted)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal hapus data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User berhasil dihapus (Soft Delete)"})
}