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

	// Import Docs (Wajib underscore agar init() jalan)
	_ "github.com/wahyualif23014/backendGO/docs"
)

// Inisialisasi Environment & Database
func init() {
	initializers.LoadEnvVariables()
	initializers.ConnectToDB()
	initializers.SyncDatabase()
}

// @title           Backend API Polres & Polsek (Sistem NRP)
// @version         1.1
// @description     API Service untuk Manajemen User (Login NRP), Validasi Akun, dan Pelaporan Data Kepolisian.
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
	
	r.POST("/signup", controllers.Signup) // Register (Status default: Pending)
	r.POST("/login", controllers.Login)   // Login (Hanya Status Active)

	// --- 4. Protected Routes (Wajib Login & Punya Token) ---
	authorized := r.Group("/")
	authorized.Use(middleware.RequireAuth)

	{
		// A. ADMIN GROUP: Manajemen User
		// Hanya bisa diakses oleh Role "admin"
		adminRoutes := authorized.Group("/admin")
		adminRoutes.Use(middleware.RequireRoles(models.RoleAdmin))
		{
			adminRoutes.POST("/users", controllers.CreateUser)            // Create (Langsung Active)
			adminRoutes.GET("/users", controllers.GetUsers)               // Read All
			adminRoutes.GET("/users/:id", controllers.GetUserByID)        // Read One
			adminRoutes.PUT("/users/:id", controllers.UpdateUser)         // Update Data
			adminRoutes.DELETE("/users/:id", controllers.DeleteUser)      // Soft Delete
			
			// FITUR BARU: Validasi Akun
			adminRoutes.PUT("/users/:id/approve", controllers.ApproveUser) // Ubah Pending -> Active
		}

		// B. INPUT GROUP: Input Laporan
		// Bisa diakses: Polres, Polsek, Admin
		inputRoutes := authorized.Group("/input")
		inputRoutes.Use(middleware.RequireRoles(models.RolePolres, models.RolePolsek, models.RoleAdmin))
		{
			inputRoutes.POST("/laporan", func(c *gin.Context) {
				// TODO: Sambungkan ke controller laporan nanti
				c.JSON(200, gin.H{"message": "Laporan berhasil diinput"})
			})
		}

		// C. VIEW GROUP: Dashboard & Monitoring
		// Bisa diakses: Semua User Active
		viewRoutes := authorized.Group("/view")
		viewRoutes.Use(middleware.RequireRoles(models.RoleView, models.RoleAdmin, models.RolePolres, models.RolePolsek))
		{
			viewRoutes.GET("/dashboard", func(c *gin.Context) {
				user, _ := c.Get("user")
				userData := user.(models.User)
				
				c.JSON(200, gin.H{
					"message":       "Dashboard Data",
					"nama_lengkap":  userData.NamaLengkap,
					"nrp":           userData.NRP,
					"jabatan":       userData.Jabatan,
					"role":          userData.Role,
					"status":        userData.Status, // Penting agar Frontend tahu statusnya
				})
			})
		}
	}

	r.Run() // Default port 8080
}