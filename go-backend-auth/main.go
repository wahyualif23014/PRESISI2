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

	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "SIKAP PRESISI Backend v2.0 Online"})
	})

	r.POST("/signup", controllers.Signup)
	r.POST("/login", controllers.Login)

	api := r.Group("/api")
	api.Use(middleware.RequireAuth)
	{
		// A. ADMIN ONLY RESOURCE (/api/admin)
		admin := api.Group("/admin")
		admin.Use(middleware.RequireRoles(models.RoleAdmin))
		{
			// Personel Management
			admin.POST("/users", controllers.CreateUser)
			admin.GET("/users", controllers.GetUsers)
			admin.GET("/users/:id", controllers.GetUserByID)
			admin.PUT("/users/:id", controllers.UpdateUser)
			admin.DELETE("/users/:id", controllers.DeleteUser)

			// Master Jabatan CUD
			admin.GET("/jabatan", controllers.GetJabatan)
			admin.POST("/jabatan", controllers.CreateJabatan)
			admin.PUT("/jabatan/:id", controllers.UpdateJabatan)
			admin.DELETE("/jabatan/:id", controllers.DeleteJabatan)

			// Data Wilayah & Tingkat
			admin.GET("/tingkat", controllers.GetTingkat)
			admin.GET("/wilayah", controllers.GetWilayah)
			admin.PUT("/wilayah/:id", controllers.UpdateWilayah)

			// --- KOMODITAS MANAGEMENT (ADMIN AREA) ---
			admin.GET("/categories", controllers.GetCategories)
			admin.POST("/categories", controllers.CreateCommodity)
			admin.POST("/categories/delete", controllers.DeleteCategory)
			admin.GET("/commodities", controllers.GetCommodities)
			admin.POST("/commodity/update", controllers.UpdateCommodity)
			admin.POST("/commodity/delete-item", controllers.DeleteCommodityItem)

			admin.GET("", controllers.GetPotensiLahan)
			admin.GET("/filters", controllers.GetFilterOptions)
			admin.POST("", controllers.CreatePotensiLahan)
			admin.PUT("/:id", controllers.UpdatePotensiLahan)
			admin.DELETE("/:id", controllers.DeletePotensiLahan)
			admin.GET("/summary", controllers.GetSummaryLahan)
			admin.GET("/no-potential", controllers.GetNoPotentialLahan)

			admin.GET("/recap", func(c *gin.Context) {
				c.JSON(200, gin.H{"message": "Full Recap Data"})
			})
		}

		// B. DATA INPUT & OPERATIONAL (/api/input)
		input := api.Group("/input")
		input.Use(middleware.RequireRoles(models.RoleAdmin, models.RoleOperator))
		{
			input.POST("/laporan", func(c *gin.Context) { c.JSON(200, gin.H{"message": "Input Sukses"}) })
			input.POST("/lahan", func(c *gin.Context) { c.JSON(200, gin.H{"message": "Input Lahan Sukses"}) })
			input.GET("", controllers.GetPotensiLahan)
			input.GET("/filters", controllers.GetFilterOptions)
			input.POST("", controllers.CreatePotensiLahan)
			input.PUT("/:id", controllers.UpdatePotensiLahan)
			input.DELETE("/:id", controllers.DeletePotensiLahan)
			input.GET("/summary", controllers.GetSummaryLahan)
			input.GET("/no-potential", controllers.GetNoPotentialLahan)
		}

		// C. GENERAL VIEW (/api/view)
		view := api.Group("/view")
		{
			view.GET("/dashboard", func(c *gin.Context) {
				u, _ := c.Get("user")
				c.JSON(200, gin.H{"user_info": u})
			})
		}
	}

	r.Run()
}
