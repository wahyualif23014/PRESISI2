package models

// Tingkat merepresentasikan tabel 'tingkat' yang asli
type Tingkat struct {
	Kode string `json:"kode" gorm:"primaryKey;column:id_tingkat"` // PK String
	Nama string `json:"nama" gorm:"column:nama_tingkat"`
}

func (Tingkat) TableName() string {
	return "tingkat"
}
