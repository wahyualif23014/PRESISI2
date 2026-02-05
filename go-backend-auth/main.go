package main

import (
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	// Library Swagger
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	// Internal Packages
	"github.com/wahyualif23014/backendGO/controllers"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/middleware"
	"github.com/wahyualif23014/backendGO/models"

	// Import Docs
	_ "github.com/wahyualif23014/backendGO/docs"
)

// Inisialisasi Environment & Database
func init() {
	initializers.LoadEnvVariables()
	initializers.ConnectToDB()
	initializers.SyncDatabase()
}

// @title           Backend API Polres & Polsek (Sistem NRP)
// @version         1.3
// @description     API Service untuk Manajemen User (Login NRP) dan Pelaporan Data Kepolisian.
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

	// --- 1. Konfigurasi CORS ---
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

	// --- 3. Public Routes ---
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "pong"})
	})

	r.POST("/signup", controllers.Signup) // Register (Default Role: View)
	r.POST("/login", controllers.Login)   // Login (Semua User)

	// --- 4. Protected Routes ---
	authorized := r.Group("/")
	authorized.Use(middleware.RequireAuth)

	{
		adminRoutes := authorized.Group("/admin")
		adminRoutes.Use(middleware.RequireRoles(models.RoleAdmin))
		{
			// --- User Management ---
			adminRoutes.POST("/users", controllers.CreateUser)       // Create User
			adminRoutes.GET("/users", controllers.GetUsers)          // Read All
			adminRoutes.GET("/users/:id", controllers.GetUserByID)   // Read One
			adminRoutes.PUT("/users/:id", controllers.UpdateUser)    // Update Data & Upgrade Role
			adminRoutes.DELETE("/users/:id", controllers.DeleteUser) // Soft Delete

			// 1. Wilayah
			adminRoutes.POST("/wilayah", controllers.CreateWilayah)
			adminRoutes.GET("/wilayah", controllers.GetWilayah)

			// 2. Polres
			adminRoutes.POST("/polres", controllers.CreatePolres)
			adminRoutes.GET("/polres", controllers.GetPolres)

			// 3. Polsek
			adminRoutes.POST("/polsek", controllers.CreatePolsek)
			adminRoutes.GET("/polsek", controllers.GetPolsek)
		}

		// B. INPUT GROUP: Input Laporan
		inputRoutes := authorized.Group("/input")
		inputRoutes.Use(middleware.RequireRoles(models.RolePolres, models.RolePolsek, models.RoleAdmin))
		{
			inputRoutes.POST("/laporan", func(c *gin.Context) {
				// TODO: Sambungkan ke controller laporan nanti
				c.JSON(200, gin.H{"message": "Laporan berhasil diinput"})
			})
		}

		viewRoutes := authorized.Group("/view")
		viewRoutes.Use(middleware.RequireRoles(models.RoleView, models.RoleAdmin, models.RolePolres, models.RolePolsek))
		{
			viewRoutes.GET("/dashboard", func(c *gin.Context) {
				// Mengambil data user dari Middleware (RequireAuth)
				user, _ := c.Get("user")
				userData := user.(models.User)

				c.JSON(200, gin.H{
					"message":      "Dashboard Data",
					"id":           userData.ID,
					"nama_lengkap": userData.NamaLengkap,
					"nrp":          userData.NRP,
					"jabatan":      userData.Jabatan,
					"role":         userData.Role,

					"no_telp":     userData.NoTelp,
					"foto_profil": userData.FotoProfil,
				})
			})
		}
	}

	// Menjalankan server
	r.Run()
}
