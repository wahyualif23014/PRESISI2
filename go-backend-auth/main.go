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
		c.JSON(200, gin.H{"message": "pong - Backend v2.0 Online"})
	})

	r.POST("/signup", controllers.Signup)
	r.POST("/login", controllers.Login)

	authorized := r.Group("/")
	authorized.Use(middleware.RequireAuth)

	{
		// --- JABATAN ROUTES (FIXED URL: /jabatan) ---
		// GET: Bisa diakses semua user yang login
		authorized.GET("/jabatan", controllers.GetJabatan)

		// CUD: Hanya ADMIN yang bisa Create/Update/Delete
		authorized.POST("/jabatan", middleware.RequireRoles(models.RoleAdmin), controllers.CreateJabatan)
		authorized.PUT("/jabatan/:id", middleware.RequireRoles(models.RoleAdmin), controllers.UpdateJabatan)
		authorized.DELETE("/jabatan/:id", middleware.RequireRoles(models.RoleAdmin), controllers.DeleteJabatan)

		// --- ADMIN ROUTES (URL: /admin/...) ---
		adminRoutes := authorized.Group("/admin")
		adminRoutes.Use(middleware.RequireRoles(models.RoleAdmin))
		{
			adminRoutes.POST("/users", controllers.CreateUser)
			adminRoutes.GET("/users", controllers.GetUsers)
			adminRoutes.GET("/users/:id", controllers.GetUserByID)
			adminRoutes.PUT("/users/:id", controllers.UpdateUser)
			adminRoutes.DELETE("/users/:id", controllers.DeleteUser)

			adminRoutes.POST("/wilayah", controllers.CreateWilayah)
			adminRoutes.GET("/wilayah", controllers.GetWilayah)
		}

		// --- INPUT ROUTES ---
		inputRoutes := authorized.Group("/input")
		inputRoutes.Use(middleware.RequireRoles(models.RoleAdmin, models.RolePolres))
		{
			inputRoutes.POST("/laporan", func(c *gin.Context) {
				c.JSON(200, gin.H{"message": "Laporan berhasil diinput"})
			})
		}

		// --- VIEW ROUTES ---
		viewRoutes := authorized.Group("/view")
		viewRoutes.Use(middleware.RequireRoles(models.RoleAdmin, models.RolePolres, models.RoleView))
		{
			viewRoutes.GET("/dashboard", func(c *gin.Context) {
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
	}

	r.Run()
}