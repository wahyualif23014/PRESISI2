package models

import "time"

// Sesuaikan struct dengan tabel 'komoditi' di SQL
type Komoditi struct {
	IDKomoditi      uint64    `gorm:"column:id_komoditi;primaryKey;autoIncrement"`
	JenisKomoditi   string    `gorm:"column:jenis_komoditi"` // Kolom ini ada di SQL
	NamaKomoditi    string    `gorm:"column:nama_komoditi"`
	IDAnggota       uint64    `gorm:"column:id_anggota"`
	DeleteStatus    string    `gorm:"column:deletestatus;default:'2'"`
	DateTransaction time.Time `gorm:"column:datetransaction"`
}

// Pastikan TableName mengembalikan 'komoditi' (bukan komoditas)
func (Komoditi) TableName() string {
	return "komoditi"
}

// Struct Response (Sesuaikan dengan kebutuhan Flutter)
type CategoryResponse struct {
	ID    string   `json:"id"`
	Title string   `json:"title"`
	Tags  []string `json:"tags"`
}

type CommodityItemResponse struct {
	ID         string `json:"id"`
	CategoryID string `json:"categoryId"`
	Name       string `json:"name"`
	IsSelected bool   `json:"isSelected"`
}
