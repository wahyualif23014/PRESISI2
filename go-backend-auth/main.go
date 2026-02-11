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

	_ "github.com/wahyualif23014/backendGO/docs"
)

// Inisialisasi Environment & Database
func init() {
	initializers.LoadEnvVariables()
	initializers.ConnectToDB()
	initializers.SyncDatabase()
}

// @title           Backend API Kepolisian (Sistem Anggota & Laporan)
// @version         2.0
// @description     API Service untuk Manajemen Anggota (Login via Username) dan Pelaporan Data Kepolisian.
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
		AllowOrigins:     []string{"*"}, // Ganti dengan domain spesifik jika produksi
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
		c.JSON(200, gin.H{"message": "pong - Backend v2.0 Online"})
	})

	r.POST("/signup", controllers.Signup) // Register (Default Role: View)
	r.POST("/login", controllers.Login)   // Login (Semua User)

	// --- 4. Protected Routes ---
	authorized := r.Group("/")
	authorized.Use(middleware.RequireAuth) // Middleware Cek Token & User Aktif
	{
		// A. ADMIN GROUP (Hanya Role '1')
		adminRoutes := authorized.Group("/admin")
		adminRoutes.Use(middleware.RequireRoles(models.RoleAdmin))
		{
			// --- User Management ---
			adminRoutes.POST("/users", controllers.CreateUser)      // Create User
			adminRoutes.GET("/users", controllers.GetUsers)         // Read All
			adminRoutes.GET("/users/:id", controllers.GetUserByID)  // Read One
			adminRoutes.PUT("/users/:id", controllers.UpdateUser)   // Update Data & Upgrade Role
			adminRoutes.DELETE("/users/:id", controllers.DeleteUser) // Soft Delete (deletestatus='1')

			adminRoutes.GET("/jabatan", controllers.GetJabatan)          // Lihat Semua Jabatan
			adminRoutes.POST("/jabatan", controllers.CreateJabatan)      // Tambah Jabatan
			adminRoutes.PUT("/jabatan/:id", controllers.UpdateJabatan)   // Edit Jabatan
			adminRoutes.DELETE("/jabatan/:id", controllers.DeleteJabatan) // Hapus Jabatan

			adminRoutes.POST("/wilayah", controllers.CreateWilayah)
			adminRoutes.GET("/wilayah", controllers.GetWilayah)
		}

		// B. INPUT GROUP (Admin & Polres)
		inputRoutes := authorized.Group("/input")
		inputRoutes.Use(middleware.RequireRoles(models.RoleAdmin, models.RolePolres))
		{
			inputRoutes.POST("/laporan", func(c *gin.Context) {
				c.JSON(200, gin.H{"message": "Laporan berhasil diinput"})
			})
		}

		// C. VIEW GROUP (Semua User Aktif: '1', '2', '3')
		viewRoutes := authorized.Group("/view")
		viewRoutes.Use(middleware.RequireRoles(models.RoleAdmin, models.RolePolres, models.RoleView))
		{
			// Route Baru: Tingkat Kesatuan
			viewRoutes.GET("/tingkat", controllers.GetTingkat)

			viewRoutes.GET("/dashboard", func(c *gin.Context) {
				userValue, exists := c.Get("user")
				if !exists {
					c.JSON(401, gin.H{"error": "Unauthorized"})
					return
				}

				// Casting ke model User yang baru
				userData := userValue.(models.User)

				c.JSON(200, gin.H{
					"message": "Dashboard Data Loaded",
					"user_info": gin.H{
						"id":           userData.ID,          // idanggota
						"nama_lengkap": userData.NamaLengkap, // nama
						"id_tugas":     userData.IDTugas,     // idtugas
						"username":     userData.Username,    // username
						"id_jabatan":   userData.JabatanID,   // idjabatan
						"role":         userData.Role,        // statusadmin (1/2/3)
						"no_telp":      userData.NoTelp,      // hp
					},
				})
			})
		}
	} // Penutup Authorized Group

	// --- JALANKAN SERVER ---
	r.Run(":8080")
}