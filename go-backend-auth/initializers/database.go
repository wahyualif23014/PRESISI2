package initializers

import (
    "log"
    "os"

    "gorm.io/driver/mysql" // Pastikan driver ini di-import
    "gorm.io/gorm"
)

var DB *gorm.DB

func ConnectToDB() {
    var err error
    dsn := os.Getenv("DB_URL")
    
    DB, err = gorm.Open(mysql.Open(dsn), &gorm.Config{})

    if err != nil {
        log.Fatal("Gagal koneksi ke database: ", err)
    }
}