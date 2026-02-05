package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
	"golang.org/x/crypto/bcrypt"
)

// --- STRUCTS UNTUK SWAGGER ---

// CreateUserInput digunakan oleh Admin untuk menambah user baru
type CreateUserInput struct {
	NamaLengkap string      `json:"nama_lengkap" binding:"required" example:"Budi Santoso"`
	NRP         string      `json:"nrp" binding:"required" example:"87011234"`
	Jabatan     string      `json:"jabatan" binding:"required" example:"Kanit Reskrim"`
	Password    string      `json:"password" binding:"required" example:"rahasia123"`
	Role        models.Role `json:"role" binding:"required" example:"polres"` // Admin wajib isi Role
	NoTelp      string      `json:"no_telp" binding:"required" example:"08123456789"`
}

// UpdateUserInput digunakan oleh Admin untuk edit user
type UpdateUserInput struct {
	NamaLengkap string      `json:"nama_lengkap" binding:"omitempty" example:"Budi Santoso S.H."`
	Jabatan     string      `json:"jabatan" binding:"omitempty" example:"Kapolsek"`
	Role        models.Role `json:"role" binding:"omitempty" example:"polres"`
	NoTelp      string      `json:"no_telp" binding:"omitempty"`
}

// --- HANDLERS ---

// CreateUser godoc
// @Summary      Tambah User Baru (Admin Only)
// @Description  Membuat user baru dengan NRP dan Role tertentu.
// @Tags         admin-users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body CreateUserInput true "Data User Baru"
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Router       /admin/users [post]
func CreateUser(c *gin.Context) {
	var body CreateUserInput

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal membaca body request: " + err.Error()})
		return
	}

	// Validasi Role
	switch body.Role {
	case models.RoleAdmin, models.RoleView, models.RolePolres, models.RolePolsek:
		// Valid
	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Role tidak valid"})
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
		KataSandi:    string(hash),
		Role:        body.Role, // Admin menentukan Role
		FotoProfil:  "",
		NoTelp:      body.NoTelp,
	}

	result := initializers.DB.Create(&user)

	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal menyimpan user. NRP mungkin sudah terdaftar."})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User berhasil ditambahkan", "data": user})
}

// GetUsers godoc
// @Summary      Lihat Semua User
// @Description  Mengambil list semua user yang terdaftar.
// @Tags         admin-users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]interface{}
// @Failure      500  {object}  map[string]string
// @Router       /admin/users [get]
func GetUsers(c *gin.Context) {
	var users []models.User
	// Select specific fields to avoid sending passwords
	result := initializers.DB.Select("id", "nama_lengkap", "nrp", "jabatan", "role", "foto_profil", "no_telp").Find(&users)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": users})
}

// GetUserByID godoc
// @Summary      Lihat Detail User
// @Description  Mengambil data user berdasarkan ID.
// @Tags         admin-users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id   path      int  true  "User ID"
// @Success      200  {object}  map[string]interface{}
// @Failure      404  {object}  map[string]string
// @Router       /admin/users/{id} [get]
func GetUserByID(c *gin.Context) {
	id := c.Param("id")
	var user models.User

	// Gunakan Select agar lebih efisien dan aman
	result := initializers.DB.Select("id", "nama_lengkap", "nrp", "jabatan", "role", "foto_profil", "no_telp").First(&user, id)

	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": user})
}

// UpdateUser godoc
// @Summary      Edit Data User (Termasuk Upgrade Role)
// @Description  Mengupdate Nama, Jabatan, Role, atau No Telp user.
// @Tags         admin-users
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id      path   int              true  "User ID"
// @Param        request body   UpdateUserInput  true  "Data Update"
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
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

	// Gunakan map untuk update parsial
	updates := make(map[string]interface{})

	if body.NamaLengkap != "" {
		updates["nama_lengkap"] = body.NamaLengkap
	}
	if body.Jabatan != "" {
		updates["jabatan"] = body.Jabatan
	}
	if body.NoTelp != "" {
		updates["no_telp"] = body.NoTelp
	}
	if body.Role != "" {
		// Validasi Role
		switch body.Role {
		case models.RoleAdmin, models.RoleView, models.RolePolres, models.RolePolsek:
			updates["role"] = body.Role
		default:
			c.JSON(http.StatusBadRequest, gin.H{"error": "Role tidak valid"})
			return
		}
	}

	initializers.DB.Model(&user).Updates(updates)

	// Ambil data terbaru setelah update
	initializers.DB.First(&user, id)

	c.JSON(http.StatusOK, gin.H{"message": "Data berhasil diupdate", "data": user})
}

// DeleteUser godoc
// @Summary      Hapus User
// @Description  Soft delete user berdasarkan ID.
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