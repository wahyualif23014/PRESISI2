package models

import "time"

// NotificationQueryResult menampung hasil JOIN dari database
type NotificationQueryResult struct {
	IDLahan         uint64    `gorm:"column:idlahan"`
	NamaOperator    string    `gorm:"column:nama_operator"`
	LokasiLahan     string    `gorm:"column:lokasi_lahan"`
	LuasLahan       float64   `gorm:"column:luaslahan"`
	StatusLahan     string    `gorm:"column:statuslahan"` // Wajib ada untuk deteksi "Validasi"
	TglValid        string    `gorm:"column:tglvalid"`    // Wajib ada untuk waktu validasi
	DateTransaction time.Time `gorm:"column:datetransaction"`
}

// NotificationResponse adalah JSON yang dikirim ke Flutter
type NotificationResponse struct {
	ID    uint64 `json:"id"`
	Title string `json:"title"`
	Body  string `json:"body"`
	Time  string `json:"time"`
}
