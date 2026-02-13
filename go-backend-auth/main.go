package main

import (
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	"github.com/wahyualif23014/backendGO/controllers"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/middleware"
	"github.com/wahyualif23014/backendGO/models"

	_ "github.com/wahyualif23014/backendGO/docs"
)

func init() {
	initializers.LoadEnvVariables()
	initializers.ConnectToDB()
	initializers.SyncDatabase()
}

// @title           Backend API Kepolisian
// @version         2.0
// @host            localhost:8080
// @BasePath        /
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
func main() {
	r := gin.Default()

	// Konfigurasi CORS
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// Swagger Route
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Public Routes (Tidak butuh token)
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "pong - Backend v2.0 Online"})
	})

	r.POST("/signup", controllers.Signup)
	r.POST("/login", controllers.Login)

	// --- PROTECTED ROUTES (Butuh Token) ---
	// Menggunakan string kosong "" agar routing lebih bersih (tidak double slash)
	authorized := r.Group("")
	authorized.Use(middleware.RequireAuth)
	{
		// ==========================================
		//           API ROUTES (GENERAL)
		// ==========================================
		api := authorized.Group("/api")
		{
			// Wilayah
			api.GET("/wilayah", controllers.GetWilayah)
			api.PUT("/wilayah/:id", controllers.UpdateWilayah)

			// Kategori & Komoditas
			api.GET("/categories", controllers.GetCategories)
			api.GET("/commodities", controllers.GetCommodities)
			api.POST("/categories", controllers.CreateCommodity)
			api.POST("/categories/delete", controllers.DeleteCategory)
			api.POST("/commodity/update", controllers.UpdateCommodity)
			api.POST("/commodity/delete-item", controllers.DeleteCommodityItem)
		}

		// ==========================================
		//           JABATAN ROUTES
		// ==========================================
		// Route ini sekarang bisa diakses via /jabatan
		authorized.GET("/jabatan", controllers.GetJabatan)
		authorized.POST("/jabatan", middleware.RequireRoles(models.RoleAdmin), controllers.CreateJabatan)
		authorized.PUT("/jabatan/:id", middleware.RequireRoles(models.RoleAdmin), controllers.UpdateJabatan)
		authorized.DELETE("/jabatan/:id", middleware.RequireRoles(models.RoleAdmin), controllers.DeleteJabatan)

		// ==========================================
		//      ADMIN ROUTES (KHUSUS ADMIN)
		// ==========================================
		// PERBAIKAN: Menggunakan huruf kecil "/admin" agar sesuai dengan Flutter
		adminRoutes := authorized.Group("/admin")
		adminRoutes.Use(middleware.RequireRoles(models.RoleAdmin))
		{
			adminRoutes.POST("/users", controllers.CreateUser)
			adminRoutes.GET("/users", controllers.GetUsers)
			adminRoutes.GET("/users/:id", controllers.GetUserByID)
			adminRoutes.PUT("/users/:id", controllers.UpdateUser)
			adminRoutes.DELETE("/users/:id", controllers.DeleteUser)
		}

		// ==========================================
		//           INPUT ROUTES
		// ==========================================
		inputRoutes := authorized.Group("/input")
		inputRoutes.Use(middleware.RequireRoles(models.RoleAdmin, models.RolePolres))
		{
			inputRoutes.POST("/laporan", func(c *gin.Context) {
				c.JSON(200, gin.H{"message": "Laporan berhasil diinput"})
			})
		}

		// ==========================================
		//           VIEW ROUTES
		// ==========================================
		viewRoutes := authorized.Group("/view")
		viewRoutes.Use(middleware.RequireRoles(models.RoleAdmin, models.RolePolres, models.RoleView))
		{
			viewRoutes.GET("/tingkat", controllers.GetTingkat)

			viewRoutes.GET("/dashboard", func(c *gin.Context) {
				// Mengambil data user dari context (diset oleh middleware)
				userValue, exists := c.Get("user")
				if !exists {
					c.JSON(401, gin.H{"error": "Unauthorized"})
					return
				}

				// Type assertion ke model User
				userData := userValue.(models.User)

				c.JSON(200, gin.H{
					"message": "Dashboard Data Loaded",
					"user_info": gin.H{
						"id":           userData.ID,
						"nama_lengkap": userData.NamaLengkap,
						"id_tugas":     userData.IDTugas,
						"username":     userData.Username,
						"id_jabatan":   userData.JabatanID,
						"role":         userData.Role,
						"no_telp":      userData.NoTelp,
					},
				})
			})
		}
	}

	r.Run()
}
