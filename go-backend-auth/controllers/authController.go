package controllers

import (
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
	"golang.org/x/crypto/bcrypt"
)

// RegisterInput defines the payload for public registration
// Swagger: This struct is used for the /signup endpoint
type RegisterInput struct {
	NamaLengkap string `json:"nama_lengkap" binding:"required" example:"Budi Santoso"`
	NRP         string `json:"nrp" binding:"required" example:"12345678"`
	Jabatan     string `json:"jabatan" binding:"required" example:"Anggota Sabhara"`
	Password    string `json:"password" binding:"required" example:"password123"`
}

// LoginInput defines the payload for login
type LoginInput struct {
	NRP      string `json:"nrp" binding:"required" example:"12345678"`
	Password string `json:"password" binding:"required" example:"password123"`
}

// Signup godoc
// @Summary      Register User Baru (Public)
// @Description  Mendaftar akun baru. Default role adalah 'view'.
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request body RegisterInput true "Data Registrasi"
// @Success      200  {object}  map[string]string
// @Failure      400  {object}  map[string]string
// @Router       /signup [post]
func Signup(c *gin.Context) {
	var body RegisterInput

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data input tidak lengkap atau format salah"})
		return
	}

	// 1. Hash Password
	hash, err := bcrypt.GenerateFromPassword([]byte(body.Password), 10)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memproses password"})
		return
	}

	// 2. Create User Object
	user := models.User{
		NamaLengkap: body.NamaLengkap,
		NRP:         body.NRP,
		Jabatan:     body.Jabatan,
		Password:    string(hash),
		Role:        models.RoleView, // FORCE DEFAULT ROLE: VIEW
		FotoProfil:  "",
	}

	// 3. Save to DB
	result := initializers.DB.Create(&user)

	if result.Error != nil {
		// Check for duplicate entry (likely NRP)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal mendaftar. NRP mungkin sudah terdaftar."})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Registrasi berhasil. Silakan Login."})
}

// Login godoc
// @Summary      Login User
// @Description  Login menggunakan NRP dan Password untuk mendapatkan Token JWT.
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        request body LoginInput true "Data Login"
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Router       /login [post]
func Login(c *gin.Context) {
	var body LoginInput

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input NRP dan Password harus diisi"})
		return
	}

	// 1. Cari User berdasarkan NRP
	var user models.User
	initializers.DB.First(&user, "nrp = ?", body.NRP)

	if user.ID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "NRP atau Password salah"})
		return
	}

	// 2. Cek Password
	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(body.Password))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "NRP atau Password salah"})
		return
	}

	// 3. Generate Token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub": user.ID,
		"exp": time.Now().Add(time.Hour * 24 * 30).Unix(), // 30 Hari
	})

	tokenString, err := token.SignedString([]byte(os.Getenv("SECRET")))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat token"})
		return
	}

	// Response Login (User + Token)
	// Kita kembalikan user data juga agar frontend bisa langsung simpan state
	c.JSON(http.StatusOK, gin.H{
		"token": tokenString,
		"user": gin.H{
			"id":           user.ID,
			"nama_lengkap": user.NamaLengkap,
			"nrp":          user.NRP,
			"jabatan":      user.Jabatan,
			"role":         user.Role,
			"foto_profil":  user.FotoProfil,
		},
	})
}