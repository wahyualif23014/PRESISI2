package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
	"golang.org/x/crypto/bcrypt"
)

// --- STRUCTS UNTUK SWAGGER ---

type CreateUserInput struct {
	NamaLengkap string      `json:"nama_lengkap" example:"Budi Santoso"`
	NRP         string      `json:"nrp" example:"87011234"`
	Jabatan     string      `json:"jabatan" example:"Kanit Reskrim"`
	Password    string      `json:"password" example:"rahasia123"`
	Role        models.Role `json:"role" example:"polres"`
}

type UpdateUserInput struct {
	NamaLengkap string      `json:"nama_lengkap" example:"Budi Santoso S.H."`
	Jabatan     string      `json:"jabatan" example:"Kapolsek"`
	Role        models.Role `json:"role" example:"polres"`
}

// --- HANDLERS ---

// CreateUser godoc
// @Summary      Tambah User Baru (Admin Only)
// @Description  Membuat user baru dengan NRP dan Role tertentu (Langsung Active)
// @Tags         admin-users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body CreateUserInput true "Data User Baru"
// @Success      200  {object}  map[string]interface{}
// @Router       /admin/users [post]
func CreateUser(c *gin.Context) {
	var body CreateUserInput

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal membaca body request"})
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(body.Password), 10)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memproses password"})
		return
	}

	user := models.User{
		NamaLengkap: body.NamaLengkap,
		NRP:         body.NRP,
		Jabatan:     body.Jabatan,
		Password:    string(hash),
		Role:        body.Role,
		FotoProfil:  "",
		Status:      "active", // KARENA ADMIN YANG BUAT, LANGSUNG AKTIF
	}

	result := initializers.DB.Create(&user)

	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal menyimpan user. NRP mungkin sudah terdaftar."})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User berhasil ditambahkan", "data": user})
}

// ApproveUser godoc
// @Summary      Setujui User (Validasi Akun)
// @Description  Mengubah status user dari pending menjadi active
// @Tags         admin-users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "User ID"
// @Success      200  {object}  map[string]interface{}
// @Router       /admin/users/{id}/approve [put]
func ApproveUser(c *gin.Context) {
	id := c.Param("id")
	var user models.User

	if err := initializers.DB.First(&user, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	// Update status menjadi "active"
	initializers.DB.Model(&user).Update("status", "active")

	c.JSON(http.StatusOK, gin.H{
		"message": "User berhasil divalidasi dan diaktifkan",
		"data":    user,
	})
}

// GetUsers godoc
// @Summary      Lihat Semua User
// @Description  Mengambil list semua user yang terdaftar
// @Tags         admin-users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]interface{}
// @Router       /admin/users [get]
func GetUsers(c *gin.Context) {
	var users []models.User
	result := initializers.DB.Find(&users)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": users})
}

// GetUserByID godoc
// @Summary      Lihat Detail User
// @Description  Mengambil data user berdasarkan ID
// @Tags         admin-users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "User ID"
// @Success      200  {object}  map[string]interface{}
// @Router       /admin/users/{id} [get]
func GetUserByID(c *gin.Context) {
	id := c.Param("id")
	var user models.User
	result := initializers.DB.First(&user, id)

	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": user})
}

// UpdateUser godoc
// @Summary      Edit Data User
// @Description  Mengupdate Nama, Jabatan, atau Role user
// @Tags         admin-users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id      path   int              true  "User ID"
// @Param        request body   UpdateUserInput  true  "Data Update"
// @Success      200  {object}  map[string]interface{}
// @Router       /admin/users/{id} [put]
func UpdateUser(c *gin.Context) {
	id := c.Param("id")
	var user models.User

	if err := initializers.DB.First(&user, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	var body UpdateUserInput

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal membaca body request"})
		return
	}

	initializers.DB.Model(&user).Updates(models.User{
		NamaLengkap: body.NamaLengkap,
		Jabatan:     body.Jabatan,
		Role:        body.Role,
	})

	c.JSON(http.StatusOK, gin.H{"message": "Data berhasil diupdate", "data": user})
}

// DeleteUser godoc
// @Summary      Hapus User
// @Description  Soft delete user berdasarkan ID
// @Tags         admin-users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "User ID"
// @Success      200  {object}  map[string]string
// @Router       /admin/users/{id} [delete]
func DeleteUser(c *gin.Context) {
	id := c.Param("id")
	result := initializers.DB.Delete(&models.User{}, id)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User berhasil dihapus"})
}