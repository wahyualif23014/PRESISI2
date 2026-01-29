package main

import (
	"time"

	"github.com/gin-contrib/cors" // Import library CORS
	"github.com/gin-gonic/gin"
	"github.com/wahyualif23014/backendGO/controllers"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/middleware"
	"github.com/wahyualif23014/backendGO/models"
)

func init() {
	initializers.LoadEnvVariables()
	initializers.ConnectToDB()
	initializers.SyncDatabase()
}

func main() {
	r := gin.Default()

	// --- TAMBAHAN PENTING: CONFIG CORS ---
	// Ini agar Flutter bisa akses API tanpa kena blokir "Cross-Origin"
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"}, // Bolehkan semua origin (aman untuk development)
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"}, // Penting: Authorization header harus diizinkan
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// --- 1. Public Routes ---
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "pong"})
	})

	r.POST("/signup", controllers.Signup)
	r.POST("/login", controllers.Login)

	// --- 2. Protected Routes ---
	authorized := r.Group("/")
	authorized.Use(middleware.RequireAuth)

	{
		// A. Admin Only (User 1)
		adminRoutes := authorized.Group("/admin")
		adminRoutes.Use(middleware.RequireRoles(models.RoleAdmin))
		{
			adminRoutes.GET("/users", controllers.GetAllUsers)
		}

		// B. Input Data (User 1, 3, 4: Admin, Polres, Polsek)
		// User 2 (View) TIDAK BISA AKSES INI
		inputRoutes := authorized.Group("/input")
		inputRoutes.Use(middleware.RequireRoles(models.RolePolres, models.RolePolsek, models.RoleAdmin))
		{
			inputRoutes.POST("/laporan", func(c *gin.Context) {
				c.JSON(200, gin.H{"message": "Laporan berhasil diinput"})
			})
		}

		// C. View Data (User 1, 2, 3, 4: Semua Role)
		viewRoutes := authorized.Group("/view")
		viewRoutes.Use(middleware.RequireRoles(models.RoleView, models.RoleAdmin, models.RolePolres, models.RolePolsek))
		{
			viewRoutes.GET("/dashboard", func(c *gin.Context) {
				user, _ := c.Get("user")
				c.JSON(200, gin.H{
					"message":         "Dashboard Data",
					"user_requesting": user.(models.User).Name,
					"role":            user.(models.User).Role,
				})
			})
		}
	}

	r.Run() // Default port 8080
}