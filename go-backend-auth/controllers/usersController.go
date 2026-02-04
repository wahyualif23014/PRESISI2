package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
	"golang.org/x/crypto/bcrypt"
)

// --- STRUCTS UNTUK SWAGGER ---
// Kita harus definisikan di luar agar Swagger bisa membaca Schema-nya

type CreateUserInput struct {
	Name        string      `json:"nama" example:"Kapolres A"`
	Email       string      `json:"email" example:"kapolres@polri.go.id"`
	Password    string      `json:"password" example:"rahasia123"`
	Role        models.Role `json:"role" example:"polres"`
	SatuanKerja string      `json:"satuan_kerja" example:"POLRES JOMBANG"`
}

type UpdateUserInput struct {
	Name        string      `json:"nama" example:"Kapolres A Edit"`
	Role        models.Role `json:"role" example:"polres"`
	SatuanKerja string      `json:"satuan_kerja" example:"POLRES JOMBANG"`
}

// --- HANDLERS ---

// CreateUser godoc
// @Summary      Tambah User Baru (Admin Only)
// @Description  Membuat user baru dengan role tertentu
// @Tags         admin-users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body CreateUserInput true "Data User Baru"
// @Success      200  {object}  map[string]interface{}
// @Router       /admin/users [post]
func CreateUser(c *gin.Context) {
	var body CreateUserInput // Gunakan struct yang sudah didefinisikan di atas

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
		Name:        body.Name,
		Email:       body.Email,
		Password:    string(hash),
		Role:        body.Role,
		SatuanKerja: body.SatuanKerja,
	}

	result := initializers.DB.Create(&user)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan user (Email mungkin duplikat)"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User berhasil ditambahkan", "data": user})
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
// @Description  Mengupdate Nama, Role, atau Satuan Kerja user
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

	var body UpdateUserInput // Gunakan struct bernama

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal membaca body request"})
		return
	}

	initializers.DB.Model(&user).Updates(models.User{
		Name:        body.Name,
		Role:        body.Role,
		SatuanKerja: body.SatuanKerja,
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