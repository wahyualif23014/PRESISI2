package models

import "time"

type Polsek struct {
	ID           uint   `gorm:"primaryKey;column:id_polsek" json:"id_polsek"`
	NamaPolsek   string `gorm:"type:varchar(50);not null" json:"nama_polsek"`
	Kapolsek     string `gorm:"type:varchar(50);not null" json:"kapolsek"`
	NoTelpPolsek string `gorm:"type:varchar(20)" json:"no_telp_polsek"`
	Kode         string `gorm:"type:varchar(20)" json:"kode"`

	// Foreign Key ke Polres (Hirarki Komando)
	PolresID  uint `gorm:"column:id_polres;type:int;not null" json:"id_polres"`
	Polres   Polres `gorm:"foreignKey:PolresID;references:ID" json:"polres,omitempty"`

	// Foreign Key ke Wilayah (Lokasi Fisik)
	WilayahID uint `gorm:"column:id_wilayah;type:int;not null" json:"id_wilayah"`
	Wilayah   Wilayah `gorm:"foreignKey:WilayahID;references:ID" json:"wilayah,omitempty"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (Polsek) TableName() string {
	return "polsek"
}