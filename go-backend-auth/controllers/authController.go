package controllers

import (
	"net/http"
	"os"
	"time" // Pastikan package time di-import

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
	"golang.org/x/crypto/bcrypt"
)

// --- STRUCTS (DTO) ---

// RegisterInput mendefinisikan payload registrasi
type RegisterInput struct {
	NamaLengkap string `json:"nama_lengkap" binding:"required" example:"Budi Santoso"`
	IDTugas     string `json:"id_tugas" binding:"required" example:"87011234"`     // Kolom idtugas
	Username    string `json:"username" binding:"required" example:"budi87"`       // Kolom username
	JabatanID   uint64 `json:"id_jabatan" binding:"required" example:"1"`          // Kolom idjabatan (BigInt)
	Password    string `json:"password" binding:"required" example:"password123"`
	NoTelp      string `json:"no_telp" binding:"required" example:"08123456789"`   // Kolom hp
}

// LoginInput mendefinisikan payload login
type LoginInput struct {
	Username string `json:"username" binding:"required" example:"budi87"`
	Password string `json:"password" binding:"required" example:"password123"`
}

// --- HANDLERS ---

// Signup godoc
// @Summary      Register User Baru (Public)
// @Description  Mendaftar akun baru dengan status 'View' (3).
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
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data salah: " + err.Error()})
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
		NamaLengkap:  body.NamaLengkap,
		IDTugas:      body.IDTugas,    // Maps to idtugas
		Username:     body.Username,   // Maps to username
		JabatanID:    &body.JabatanID, // Maps to idjabatan
		KataSandi:    string(hash),
		NoTelp:       body.NoTelp,         // Maps to hp
		Role:         models.RoleView,     // Default '3' (View)
		DeleteStatus: models.StatusActive, // Default '2' (Aktif)
		IDPengguna:   1,                   // Default Value (Wajib Not Null di DB)
		
		// --- PERBAIKAN: Set Waktu Transaksi ---
		DateTransaction: time.Now(), 
	}

	// 3. Save to DB
	result := initializers.DB.Create(&user)

	if result.Error != nil {
		// Tampilkan detail error jika gagal (berguna untuk debugging)
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Gagal mendaftar. Username atau ID Tugas mungkin sudah digunakan.",
			"detail": result.Error.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Registrasi berhasil. Silakan Login."})
}

// Login godoc
// @Summary      Login User
// @Description  Login menggunakan Username dan Password.
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
		c.JSON(http.StatusBadRequest, gin.H{"error": "Username dan Password harus diisi"})
		return
	}

	var user models.User

	// 1. Cari User berdasarkan Username & Pastikan User Aktif ('2')
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
		"sub": user.ID,                                      // Menggunakan idanggota
		"exp": time.Now().Add(time.Hour * 24 * 30).Unix(), // Expire 30 Hari
	})

	tokenString, err := token.SignedString([]byte(os.Getenv("SECRET")))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat token"})
		return
	}

	// Response Login
	c.JSON(http.StatusOK, gin.H{
		"token": tokenString,
		"user": gin.H{
			"id":           user.ID,
			"nama_lengkap": user.NamaLengkap,
			"id_tugas":     user.IDTugas,   // ID Tugas
			"username":     user.Username,  // Username
			"id_jabatan":   user.JabatanID, // ID Jabatan
			"role":         user.Role,      // Role (1/2/3)
			"no_telp":      user.NoTelp,
		},
	})
}