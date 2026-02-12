package models

import (
	"time"
)

// 1. Model Anggota
type Anggota struct {
	ID          uint64 `gorm:"column:idanggota;primaryKey"`
	NamaLengkap string `gorm:"column:nama_lengkap"`
	NRP         string `gorm:"column:nrp"`
}

func (Anggota) TableName() string {
	return "anggota"
}

// 2. Model Jabatan
type Jabatan struct {
	ID           uint64 `gorm:"column:idjabatan;primaryKey;autoIncrement" json:"id"`
	NamaJabatan  string `gorm:"column:namajabatan;size:100" json:"nama_jabatan"`
	DeleteStatus string `gorm:"column:deletestatus;type:enum('1','2');default:'2'" json:"-"`

	// Foreign Key
	IDAnggota *uint64 `gorm:"column:idanggota" json:"-"`

	DateTransaction time.Time `gorm:"column:datetransaction" json:"created_at"`

	// FIX: Tambahkan struct relasi untuk GORM Preload
	// foreignKey merujuk ke field di struct ini (IDAnggota)
	// references merujuk ke field di struct tujuan (ID pada Anggota)
	AnggotaDetail *Anggota `gorm:"foreignKey:IDAnggota;references:ID" json:"-"`
}

func (Jabatan) TableName() string {
	return "jabatan"
}

// 3. Response DTO
type JabatanResponse struct {
	ID               uint64 `json:"id"`
	NamaJabatan      string `json:"nama_jabatan"`
	NamaPejabat      string `json:"nama_pejabat"`      // Dari AnggotaDetail.NamaLengkap
	NRP              string `json:"nrp"`               // Dari AnggotaDetail.NRP
	TanggalPeresmian string `json:"tanggal_peresmian"` // Format String YYYY-MM-DD
}
