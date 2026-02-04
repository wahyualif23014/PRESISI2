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

func RequireAuth(c *gin.Context) {
	// 1. Ambil header Authorization
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Authorization header missing"})
		return
	}

	// 2. Support format "Bearer <token>"
	tokenString := authHeader
	if len(strings.Split(authHeader, " ")) == 2 {
		tokenString = strings.Split(authHeader, " ")[1]
	}

	// 3. Parse Token
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(os.Getenv("SECRET")), nil
	})

	// Jika parsing gagal atau token invalid
	if err != nil || !token.Valid {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
		return
	}

	// 4. Validasi Claims & Expiration
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid token claims"})
		return
	}

	if float64(time.Now().Unix()) > claims["exp"].(float64) {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Token expired"})
		return
	}

	// 5. Query DB (OPTIMIZED)
	// Kita ambil data user berdasarkan ID dari token.
	// Field 'status' sudah tidak perlu diambil karena sudah dihapus dari Model.
	var user models.User
	result := initializers.DB.Select("id", "nama_lengkap", "nrp", "role", "jabatan").First(&user, claims["sub"])

	if result.Error != nil || user.ID == 0 {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "User not found or deleted"})
		return
	}

	// 6. Set user ke context
	c.Set("user", user)
	c.Next()
}

func RequireRoles(allowedRoles ...models.Role) gin.HandlerFunc {
	return func(c *gin.Context) {
		// 1. Ambil user dari context dengan aman
		userValue, exists := c.Get("user")
		if !exists {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized session"})
			return
		}

		// 2. Type Assertion
		user, ok := userValue.(models.User)
		if !ok {
			c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "User context error"})
			return
		}

		// 3. Cek Role
		isAllowed := false
		for _, role := range allowedRoles {
			if user.Role == role {
				isAllowed = true
				break
			}
		}

		if !isAllowed {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"error":   "Access denied",
				"message": fmt.Sprintf("Role '%s' tidak diizinkan mengakses resource ini. Hubungi Admin.", user.Role),
			})
			return
		}

		c.Next()
	}
}