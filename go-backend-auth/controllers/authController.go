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

// Input Register
type RegisterInput struct {
	NamaLengkap string `json:"nama_lengkap" binding:"required"`
	NRP         string `json:"nrp" binding:"required"`
	Jabatan     string `json:"jabatan" binding:"required"`
	Password    string `json:"password" binding:"required"`
	// Role tidak wajib di-bind dari JSON saat Signup publik, 
	// karena kita akan paksa jadi 'view'
}

// Input Login
type LoginInput struct {
	NRP      string `json:"nrp" binding:"required"`
	Password string `json:"password" binding:"required"`
}

func Signup(c *gin.Context) {
	var body RegisterInput

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data input tidak lengkap"})
		return
	}

	// Hash Password
	hash, err := bcrypt.GenerateFromPassword([]byte(body.Password), 10)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memproses password"})
		return
	}

	// Create User
	user := models.User{
		NamaLengkap: body.NamaLengkap,
		NRP:         body.NRP,
		Jabatan:     body.Jabatan,
		Password:    string(hash),
		// FORCE DEFAULT ROLE: VIEW
		// User yang daftar sendiri hanya bisa melihat data dashboard umum.
		// Admin harus meng-update role mereka nanti menjadi 'polsek'/'polres'.
		Role:        models.RoleView, 
		FotoProfil:  "",
	}

	result := initializers.DB.Create(&user)

	if result.Error != nil {
		// Error biasanya karena NRP Duplicate
		c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal mendaftar. NRP mungkin sudah terdaftar."})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Registrasi berhasil. Silakan Login."})
}

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
	c.JSON(http.StatusOK, gin.H{
		"token": tokenString,
		"user":  user,
	})
}