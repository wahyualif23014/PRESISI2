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

func main() {
	r := gin.Default()

	// 1. KONFIGURASI CORS
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// ==========================================
	// 2. PUBLIC ROUTES (BEBAS AKSES)
	// ==========================================

	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "pong - Backend Online"})
	})

	r.POST("/signup", controllers.Signup)
	r.POST("/login", controllers.Login)
	r.GET("/jabatan", controllers.GetJabatan)

	publicApi := r.Group("/api")
	{
		// Potensi Lahan
		lahan := publicApi.Group("/potensi-lahan")
		{
			lahan.GET("", controllers.GetPotensiLahan)
			lahan.GET("/filters", controllers.GetFilterOptions)
			lahan.POST("", controllers.CreatePotensiLahan)
			lahan.PUT("/:id", controllers.UpdatePotensiLahan)
			lahan.DELETE("/:id", controllers.DeletePotensiLahan)
			lahan.GET("/summary", controllers.GetSummaryLahan)
			lahan.GET("/no-potential", controllers.GetNoPotentialLahan)
		}

		// Wilayah, Kategori, Komoditas (PUBLIC)
		publicApi.GET("/wilayah", controllers.GetWilayah)
		publicApi.GET("/categories", controllers.GetCategories)
		publicApi.GET("/commodities", controllers.GetCommodities)
	}

	// --- GROUP ADMIN (PUBLIC) ---
	adminRoutes := r.Group("/admin")
	{
		adminRoutes.POST("/users", controllers.CreateUser)
		adminRoutes.GET("/users", controllers.GetUsers)
		adminRoutes.GET("/users/:id", controllers.GetUserByID)
		adminRoutes.PUT("/users/:id", controllers.UpdateUser)
		adminRoutes.DELETE("/users/:id", controllers.DeleteUser)
	}

	// --- GROUP VIEW (PUBLIC - Agar Dashboard Tingkat muncul) ---
	viewRoutes := r.Group("/view")
	{
		viewRoutes.GET("/tingkat", controllers.GetTingkat)
	}

	// ==========================================
	// 3. PROTECTED ROUTES (WAJIB LOGIN)
	// ==========================================
	authorized := r.Group("")
	authorized.Use(middleware.RequireAuth)
	{
		api := authorized.Group("/api")
		{
			// Modifikasi Data Master (Create/Update/Delete masih dilindungi)
			api.POST("/categories", controllers.CreateCommodity)
			api.POST("/categories/delete", controllers.DeleteCategory)
			api.POST("/commodity/update", controllers.UpdateCommodity)
			api.POST("/commodity/delete-item", controllers.DeleteCommodityItem)
		}

		// Modifikasi Jabatan (Hanya Admin)
		authorized.POST("/jabatan", middleware.RequireRoles(models.RoleAdmin), controllers.CreateJabatan)
		authorized.PUT("/jabatan/:id", middleware.RequireRoles(models.RoleAdmin), controllers.UpdateJabatan)
		authorized.DELETE("/jabatan/:id", middleware.RequireRoles(models.RoleAdmin), controllers.DeleteJabatan)

		// Input Laporan
		inputRoutes := authorized.Group("/input")
		inputRoutes.Use(middleware.RequireRoles(models.RoleAdmin, models.RolePolres))
		{
			inputRoutes.POST("/laporan", func(c *gin.Context) {
				c.JSON(200, gin.H{"message": "Laporan berhasil diinput"})
			})
		}

		// Dashboard User Info
		authorized.GET("/view/dashboard", func(c *gin.Context) {
			userValue, exists := c.Get("user")
			if !exists {
				c.JSON(401, gin.H{"error": "Unauthorized"})
				return
			}
			userData := userValue.(models.User)
			c.JSON(200, gin.H{
				"message": "Dashboard Data Loaded",
				"user_info": gin.H{
					"id":           userData.ID,
					"nama_lengkap": userData.NamaLengkap,
					"role":         userData.Role,
				},
			})
		})
	}

	r.Run()
}
