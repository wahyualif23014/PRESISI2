package initializers

import (
	"github.com/wahyualif23014/backendGO/models"
)

func SyncDatabase() {

	if DB != nil {
		DB.AutoMigrate(&models.User{})
	}
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
