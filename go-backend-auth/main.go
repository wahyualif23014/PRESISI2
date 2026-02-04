package main

import (
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	// Library Swagger
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	// Internal Packages (Sesuaikan path dengan go.mod Anda)
	"github.com/wahyualif23014/backendGO/controllers"
	"github.com/wahyualif23014/backendGO/initializers"
	_ "github.com/wahyualif23014/backendGO/docs"
	"github.com/wahyualif23014/backendGO/middleware"
	"github.com/wahyualif23014/backendGO/models"
)

// Inisialisasi Environment & Database sebelum aplikasi jalan
func init() {
	initializers.LoadEnvVariables()
	initializers.ConnectToDB()
	initializers.SyncDatabase()
}

// @title           Backend API Polres & Polsek
// @version         1.0
// @description     API Service untuk Manajemen User dan Pelaporan Data Kepolisian.
// @termsOfService  http://swagger.io/terms/

// @contact.name    Tim IT Support
// @contact.email   admin@polri.go.id

// @host            localhost:8080
// @BasePath        /

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
func main() {
	r := gin.Default()

	// --- 1. Konfigurasi CORS (Penting untuk Flutter) ---
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"}, // Ubah ke domain spesifik saat production
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// --- 2. Swagger Endpoint ---
	// Akses: http://localhost:8080/swagger/index.html
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// --- 3. Public Routes (Tanpa Login) ---
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "pong"})
	})
	r.POST("/signup", controllers.Signup) // Register awal (bisa dimatikan saat production)
	r.POST("/login", controllers.Login)

	// --- 4. Protected Routes (Harus Login) ---
	authorized := r.Group("/")
	authorized.Use(middleware.RequireAuth)

	{
		// A. ADMIN GROUP: Manajemen User (CRUD)
		// Hanya bisa diakses oleh Role "admin"
		adminRoutes := authorized.Group("/admin")
		adminRoutes.Use(middleware.RequireRoles(models.RoleAdmin))
		{
			adminRoutes.POST("/users", controllers.CreateUser)       // Create User
			adminRoutes.GET("/users", controllers.GetUsers)          // Read All
			adminRoutes.GET("/users/:id", controllers.GetUserByID)   // Read One
			adminRoutes.PUT("/users/:id", controllers.UpdateUser)    // Update
			adminRoutes.DELETE("/users/:id", controllers.DeleteUser) // Delete
		}

		// B. INPUT GROUP: Input Laporan
		// Bisa diakses: Polres, Polsek, Admin
		inputRoutes := authorized.Group("/input")
		inputRoutes.Use(middleware.RequireRoles(models.RolePolres, models.RolePolsek, models.RoleAdmin))
		{
			inputRoutes.POST("/laporan", func(c *gin.Context) {
				// Nanti ganti function ini dengan controller laporan yang asli
				c.JSON(200, gin.H{"message": "Laporan berhasil diinput"})
			})
		}

		// C. VIEW GROUP: Dashboard & Monitoring
		// Bisa diakses: Semua User yang login (termasuk RoleView)
		viewRoutes := authorized.Group("/view")
		viewRoutes.Use(middleware.RequireRoles(models.RoleView, models.RoleAdmin, models.RolePolres, models.RolePolsek))
		{
			viewRoutes.GET("/dashboard", func(c *gin.Context) {
				user, _ := c.Get("user")
				c.JSON(200, gin.H{
					"message":   "Dashboard Data",
					"user_name": user.(models.User).Name,
					"role":      user.(models.User).Role,
				})
			})
		}
	}

	r.Run() // Default port 8080
}