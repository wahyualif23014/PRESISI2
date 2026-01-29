package controllers

import (
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/wahyualif23014/backendGO/initializers"
	"github.com/wahyualif23014/backendGO/models"
	"golang.org/x/crypto/bcrypt"
)

func Signup(c *gin.Context) {
	var body struct {
		Name     string      `json:"name"`
		Email    string      `json:"email"`
		Password string      `json:"password"`
		Role     models.Role `json:"role"` 
	}

	if c.ShouldBindJSON(&body) != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to read body. Check your JSON format."})
		return
	}

	// Validasi sederhana: Pastikan field tidak kosong
	if body.Email == "" || body.Password == "" || body.Role == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email, Password, and Role are required"})
		return
	}

	// 2. Hash Password
	hash, err := bcrypt.GenerateFromPassword([]byte(body.Password), 10)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// 3. Create User
	user := models.User{
		Name:     body.Name,
		Email:    body.Email,
		Password: string(hash),
		Role:     body.Role,
	}

	result := initializers.DB.Create(&user)

	if result.Error != nil {
		// Biasanya error karena Duplicate Email
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to create user. Email might be taken."})
		return
	}

	// 4. Respond
	c.JSON(http.StatusOK, gin.H{"message": "User created successfully"})
}

func Login(c *gin.Context) {
	var body struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	if c.ShouldBindJSON(&body) != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to read body. Ensure raw JSON is used."})
		return
	}

	// 2. Look up requested user
	var user models.User
	initializers.DB.First(&user, "email = ?", body.Email)

	if user.ID == 0 {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	// 3. Compare password
	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(body.Password))
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	// 4. Generate JWT Token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub":  user.ID,
		"role": user.Role,                            // Menyimpan role di dalam token (opsional, tapi berguna)
		"exp":  time.Now().Add(time.Hour * 24 * 30).Unix(), // 30 Hari
	})

	tokenString, err := token.SignedString([]byte(os.Getenv("SECRET")))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create token"})
		return
	}


	c.SetSameSite(http.SameSiteLaxMode)
	c.SetCookie("Authorization", tokenString, 3600*24*30, "", "", false, true)

	c.JSON(http.StatusOK, gin.H{
		"token": tokenString,
		"user": gin.H{
			"id":   user.ID,
			"name": user.Name,
			"role": user.Role,
			"email": user.Email,
		},
	})
}

func GetAllUsers(c *gin.Context) {
	var users []models.User
	
	initializers.DB.Omit("password").Find(&users)
	
	c.JSON(200, users)
}