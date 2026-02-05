package models

import "time"

type Wilayah struct {
	// Kita custom Primary Key supaya sesuai dengan SQL kamu (id_wilayah)
	ID        uint      `gorm:"primaryKey;column:id_wilayah" json:"id_wilayah"`
	Kabupaten string    `gorm:"type:varchar(100);not null" json:"kabupaten"`
	Kecamatan string    `gorm:"type:varchar(100);not null" json:"kecamatan"`
	Latitude  float64   `gorm:"type:decimal(10,6)" json:"latitude"`
	Longitude float64   `gorm:"type:decimal(10,6)" json:"longitude"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// Override nama tabel agar GORM menggunakan 'wilayah' (bukan wilayahs)
func (Wilayah) TableName() string {
	return "wilayah"
}