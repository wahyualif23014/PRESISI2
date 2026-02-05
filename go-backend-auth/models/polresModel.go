package models

import "time"

type Polres struct {
	ID           uint   `gorm:"primaryKey;column:id_polres" json:"id_polres"`
	NamaPolres   string `gorm:"type:varchar(50);not null" json:"nama_polres"`
	Kapolres     string `gorm:"type:varchar(30);not null" json:"kapolres"`
	NoTelpPolres string `gorm:"type:varchar(20)" json:"no_telp_polres"`

	// Foreign Key ke Wilayah
	WilayahID uint `gorm:"column:id_wilayah;type:int;not null" json:"id_wilayah"`
	Wilayah   Wilayah `gorm:"foreignKey:WilayahID;references:ID" json:"wilayah,omitempty"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (Polres) TableName() string {
	return "polres"
}