package middleware

import (
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
)

// RequireAuth memvalidasi identitas pengguna melalui JWT
func RequireAuth(c *gin.Context) {
	// 1. Ambil Header Authorization
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Akses ditolak: Token tidak ditemukan"})
		return
	}

	// 2. Bersihkan Prefix "Bearer "
	tokenString := strings.TrimPrefix(authHeader, "Bearer ")

	// 3. Parse & Validasi Signature Token
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("metode signing tidak valid: %v", token.Header["alg"])
		}
		return []byte(os.Getenv("SECRET")), nil
	})

	// Penanganan Token Invalid
	if err != nil || !token.Valid {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Sesi tidak valid atau telah berakhir"})
		return
	}

	// 4. Ekstrak Claims & Cek Expiry
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Format token rusak"})
		return
	}

	if float64(time.Now().Unix()) > claims["exp"].(float64) {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Sesi telah kedaluwarsa, silakan login ulang"})
		return
	}

	// 5. Query Database (Load Full User & Relasi Jabatan)
	var user models.User
	result := initializers.DB.
		Preload("Jabatan").
		Where("idanggota = ? AND deletestatus = ?", claims["sub"], models.StatusActive).
		First(&user)

	if result.Error != nil {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Akun tidak ditemukan atau tidak aktif"})
		return
	}

	c.Set("user", user)
	c.Next()
}

func RequireRoles(allowedRoles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		// 1. Ambil data user dari context
		userValue, exists := c.Get("user")
		if !exists {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Sesi tidak ditemukan"})
			return
		}

		user := userValue.(models.User)

		isAllowed := false
		for _, role := range allowedRoles {
			if user.Role == role {
				isAllowed = true
				break
			}
		}

		if !isAllowed {
			// Mapping label role untuk pesan error yang ramah pengguna
			roleLabel := "User"
			switch user.Role {
			case models.RoleAdmin:
				roleLabel = "Administrator"
			case models.RoleOperator:
				roleLabel = "Operator"
			case models.RoleView:
				roleLabel = "View Only"
			}

			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"error":   "Akses Terbatas",
				"message": fmt.Sprintf("Level akses Anda (%s) tidak diizinkan untuk fitur ini.", roleLabel),
			})
			return
		}

		c.Next()
	}
}