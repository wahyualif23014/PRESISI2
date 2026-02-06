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

	// 2. Format "Bearer <token>"
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

	// 5. Query DB (Disetujui dengan Model Baru)
	var user models.User

	result := initializers.DB.
		Select("idanggota", "nama", "idtugas", "username", "statusadmin", "idjabatan", "hp").
		Where("idanggota = ?", claims["sub"]).           // Cari berdasarkan ID (Sub)
		Where("deletestatus = ?", models.StatusActive). // Pastikan user aktif ('2')
		First(&user)

	if result.Error != nil || user.ID == 0 {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "User not found or inactive"})
		return
	}

	// 6. Set user ke context
	c.Set("user", user)
	c.Next()
}

func RequireRoles(allowedRoles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
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
			roleLabel := "Unknown"
			switch user.Role {
			case models.RoleAdmin:
				roleLabel = "Admin"
			case models.RolePolres:
				roleLabel = "Polres"
			case models.RoleView:
				roleLabel = "View"
			}

			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"error":   "Access denied",
				"message": fmt.Sprintf("Role Level '%s' (%s) tidak diizinkan mengakses resource ini.", user.Role, roleLabel),
			})
			return
		}

		c.Next()
	}
}