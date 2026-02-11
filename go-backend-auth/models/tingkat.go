package models

// Tingkat merepresentasikan tabel 'tingkat' yang asli
type Tingkat struct {
	Kode string `json:"kode" gorm:"primaryKey;column:kode"` // PK String
	Nama string `json:"nama" gorm:"column:nama"`
	// Field DeleteStatus DIHAPUS karena tidak ada di database
}

func (Tingkat) TableName() string {
	return "tingkat"
}
