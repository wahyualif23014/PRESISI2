package initializers

import (
	"github.com/wahyualif23014/backendGO/models"
)

func SyncDatabase() {
	// Fungsi ini akan membuat tabel 'users' jika belum ada
	// Menggunakan variabel DB yang didefinisikan di database.go
	if DB != nil {
		DB.AutoMigrate(&models.User{})
	}
}