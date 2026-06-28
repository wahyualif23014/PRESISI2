package controllers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
	"golang.org/x/crypto/bcrypt"
)

type CreateUserInput struct {
	NamaLengkap string `json:"nama_lengkap" binding:"required"`
	IDTugas     string `json:"id_tugas" binding:"required"`
	Username    string `json:"username" binding:"required"`
	JabatanID   uint64 `json:"id_jabatan" binding:"required"`
	Password    string `json:"password" binding:"required"`
	Role        string `json:"role" binding:"required"`
	NoTelp      string `json:"no_telp"`
}

type UpdateUserInput struct {
	NamaLengkap string  `json:"nama_lengkap"`
	NoTelp      string  `json:"no_telp"`
	IDTugas     string  `json:"id_tugas"`
	IDJabatan   *uint64 `json:"id_jabatan"`
	Role        string  `json:"role"`
}

func CreateUser(c *gin.Context) {
	var input CreateUserInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 1. Cek duplikasi username
	var existingUser models.User
	if err := initializers.DB.Where("username = ?", input.Username).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Username sudah terdaftar"})
		return
	}

	// 2. Hashing password
	hash, err := bcrypt.GenerateFromPassword([]byte(input.Password), 10)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal enkripsi password"})
		return
	}

	// 4. Inisialisasi model sesuai skema db_pgri
	user := models.User{
		NamaLengkap:     input.NamaLengkap, // Mapping ke kolom 'nama'
		NoTelp:          input.NoTelp,      // Mapping ke kolom 'hp'
		IDTugas:         input.IDTugas,     // 'kode' unit dari tingkat
		Username:        input.Username,
		KataSandi:       string(hash),      // Mapping ke kolom 'password'
		JabatanID:       input.JabatanID,   // Tanpa & (ampersand)
		Role:            input.Role,        // Mapping ke kolom 'statusadmin'
		DeleteStatus:    "2",               // Aktif
		DateTransaction: time.Now(),
	}

	if err := initializers.DB.Omit("id_anggota").Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database Error: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "User berhasil didaftarkan",
		"data":    user,
	})
}

func GetUsers(c *gin.Context) {
	var users []models.User

	// Implementasi Preload untuk mengambil detail Jabatan & Tingkat
	err := initializers.DB.
		Preload("JabatanDetail").
		Preload("TingkatDetail"). 
		Where("deletestatus = ?", models.StatusActive).
		Find(&users).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": users})
}

func GetUserByID(c *gin.Context) {
	id := c.Param("id")
	var user models.User

	err := initializers.DB.
		Preload("JabatanDetail").
		Preload("TingkatDetail").
		Where("id_anggota = ? AND deletestatus = ?", id, models.StatusActive).
		First(&user).Error

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": user})
}

func UpdateUser(c *gin.Context) {
	id := c.Param("id")
	var input UpdateUserInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	if err := initializers.DB.Where("id_anggota = ?", id).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	updates := make(map[string]interface{})
	if input.NamaLengkap != "" { updates["nama_anggota"] = input.NamaLengkap }
	if input.NoTelp != ""      { updates["no_telp_anggota"] = input.NoTelp }
	if input.IDTugas != ""      { updates["id_tugas"] = input.IDTugas }
	if input.IDJabatan != nil   { updates["id_jabatan"] = *input.IDJabatan }
	if input.Role != ""         { updates["role"] = input.Role }

	initializers.DB.Model(&user).Updates(updates)
	c.JSON(http.StatusOK, gin.H{"message": "User updated successfully", "data": user})
}

func DeleteUser(c *gin.Context) {
	id := c.Param("id")
	result := initializers.DB.Model(&models.User{}).
		Where("id_anggota = ?", id).
		Update("deletestatus", models.StatusDeleted)

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "User deleted successfully"})
}

func GetProfile(c *gin.Context) {
	user, _ := c.Get("user")
	c.JSON(http.StatusOK, gin.H{"data": user})
}

func GetJabatanList(c *gin.Context) {
    var jabatans []models.Jabatan
    if err := initializers.DB.Where("deletestatus = ?", "2").Find(&jabatans).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data jabatan"})
        return
    }
    c.JSON(http.StatusOK, gin.H{"data": jabatans})
}

func GetTingkatList(c *gin.Context) {
    var tingkats []models.Tingkat
    if err := initializers.DB.Select("id_tingkat, nama_tingkat").Find(&tingkats).Error; err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data unit"})
        return
    }
    c.JSON(http.StatusOK, gin.H{"data": tingkats})
}