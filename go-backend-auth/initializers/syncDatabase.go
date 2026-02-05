package initializers

import (
	"log"
	"github.com/wahyualif23014/backendGO/models"
)

func SyncDatabase() {
	if DB == nil {
		log.Fatal("Database connection failed. Cannot sync.")
	}

	// Migrasi semua model sekaligus agar relasi (Foreign Key) terbentuk dengan benar
	err := DB.AutoMigrate(
		&models.User{},    // Tabel users
		&models.Wilayah{}, 
		&models.Polres{},  
		&models.Polsek{},  
	)

	if err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}

	log.Println("Database migration completed successfully!")
}
// {
//   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NzI3Njc2NjksInN1YiI6NX0.0UO0h6UkHY8na3DESGAzITghuYUAI-B0fWIfEz8CG1s",
//   "user": {
//     "ID": 5,
//     "CreatedAt": "2026-02-04T10:26:20.983+07:00",
//     "UpdatedAt": "2026-02-04T10:26:20.983+07:00",
//     "DeletedAt": null,
//     "nama_lengkap": "Jenderal Admin",
//     "nrp": "999999",
//     "jabatan": "Administrator Sistem",
//     "role": "admin",
//     "foto_profil": ""
//   }
// }
