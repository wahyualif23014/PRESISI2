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

// --- STRUCTS (DTO) ---

// RegisterInput mendefinisikan payload registrasi
type RegisterInput struct {
	NamaLengkap string `json:"nama_lengkap" binding:"required"`
	IDTugas     string `json:"id_tugas" binding:"required"`     // Sesuai DB: idtugas
	Username    string `json:"username" binding:"required"`     // Sesuai DB: username
	JabatanID   uint64 `json:"id_jabatan" binding:"required"`   
	Password    string `json:"password" binding:"required"`
	NoTelp      string `json:"no_telp" binding:"required"`      // Sesuai DB: hp
}

type LoginInput struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// --- HANDLERS ---

// Signup Handler
func Signup(c *gin.Context) {
	var body RegisterInput

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data salah: " + err.Error()})
		return
	}

	// 1. Hash Password
	hash, err := bcrypt.GenerateFromPassword([]byte(body.Password), 10)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memproses password"})
		return
	}

	// 2. Create User Object sesuai Model Terbaru
	user := models.User{
		NamaLengkap:     body.NamaLengkap,
		IDTugas:         body.IDTugas,       // Masuk ke kolom idtugas
		Username:        body.Username,      // Masuk ke kolom username
		JabatanID:       &body.JabatanID,    
		KataSandi:       string(hash),
		NoTelp:          body.NoTelp,        // Masuk ke kolom hp
		Role:            models.RoleView,    // Default '3' (View)
		DeleteStatus:    models.StatusActive,// Default '2' (Aktif)
		
		IDPengguna:      1,                  // Default System ID
		DateTransaction: time.Now(),         // Waktu Transaksi
	}

	// 3. Save to DB
	result := initializers.DB.Create(&user)

	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Gagal mendaftar. Username atau ID Tugas mungkin sudah digunakan.",
			"detail": result.Error.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Registrasi berhasil. Silakan Login."})
}

// Login Handler
func Login(c *gin.Context) {
	var body LoginInput

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Username dan Password harus diisi"})
		return
	}

	var user models.User

	result := initializers.DB.
		Where("username = ? AND deletestatus = ?", body.Username, models.StatusActive).
		First(&user)

	if result.Error != nil || user.ID == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Username atau Password salah"})
		return
	}

	// 2. Cek Password
	err := bcrypt.CompareHashAndPassword([]byte(user.KataSandi), []byte(body.Password))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Username atau Password salah"})
		return
	}

	// 3. Generate Token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub": user.ID,                                     // Simpan ID User
		"exp": time.Now().Add(time.Hour * 24 * 30).Unix(),  // Expire 30 Hari
	})

	tokenString, err := token.SignedString([]byte(os.Getenv("SECRET")))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat token"})
		return
	}

	// 4. Response Login
	c.JSON(http.StatusOK, gin.H{
		"token": tokenString,
		"user": gin.H{
			"id":           user.ID,
			"nama_lengkap": user.NamaLengkap,
			"id_tugas":     user.IDTugas,      // Penting: ID Tugas
			"username":     user.Username,     // Penting: Username Login
			"id_jabatan":   user.JabatanID,    // Penting: ID Jabatan (Int)
			"role":         user.Role,         // Role (1/2/3)
			"no_telp":      user.NoTelp,
		},
	})
}