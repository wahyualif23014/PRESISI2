package models

import (
	"time"
)

// 1. Perbaiki Model Anggota
type Anggota struct {
	// GANTI 'column:id' MENJADI 'column:idanggota' (sesuaikan dengan DB Anda)
	ID          uint64 `gorm:"column:idanggota;primaryKey"` 
	
	NamaLengkap string `gorm:"column:nama_lengkap"` 
	NRP         string `gorm:"column:nrp"`
}

func (Anggota) TableName() string {
	return "anggota" 
}

// 2. Model Jabatan (Pastikan References benar)
type Jabatan struct {
<<<<<<< HEAD
	ID              uint64    `gorm:"column:idjabatan;primaryKey;autoIncrement" json:"id"`
	NamaJabatan     string    `gorm:"column:namajabatan;size:100" json:"nama_jabatan"`
	DeleteStatus    string    `gorm:"column:deletestatus;type:enum('1','2');default:'2'" json:"-"`
	
	IDAnggota       *uint64   `gorm:"column:idanggota" json:"-"`
	
	// References:ID artinya dia akan mencocokkan IDAnggota dengan field ID milik struct Anggota
	AnggotaDetail   *Anggota  `gorm:"foreignKey:IDAnggota;references:ID" json:"-"`

=======
	ID           uint64  `gorm:"column:idjabatan;primaryKey;autoIncrement" json:"id"`
	NamaJabatan  string  `gorm:"column:namajabatan;size:100" json:"nama_jabatan"`
	DeleteStatus string  `gorm:"column:deletestatus;type:enum('1','2');default:'2'" json:"-"`
	IDAnggota    *uint64 `gorm:"column:idanggota" json:"-"`
>>>>>>> fitur-fajri
	DateTransaction time.Time `gorm:"column:datetransaction" json:"created_at"`
}

func (Jabatan) TableName() string {
	return "jabatan"
}

// ... JabatanResponse struct tetap sama ...

type JabatanResponse struct {
	ID               uint64 `json:"id"`
	NamaJabatan      string `json:"nama_jabatan"`
	NamaPejabat      string `json:"nama_pejabat"`      // <--- Ini yang diminta Flutter
	NRP              string `json:"nrp"`               // <--- Ini yang diminta Flutter
	TanggalPeresmian string `json:"tanggal_peresmian"` // <--- Format String YYYY-MM-DD
}
