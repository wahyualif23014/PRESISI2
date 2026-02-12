package models

import (
	"time"
)

// 1. Model Anggota (Sudah Benar)
type Anggota struct {
	ID          uint64 `gorm:"column:idanggota;primaryKey"` // Primary Key sesuai DB
	NamaLengkap string `gorm:"column:nama_lengkap"`
	NRP         string `gorm:"column:nrp"`
}

func (Anggota) TableName() string {
	return "anggota"
}

// 2. Model Jabatan (DITAMBAHKAN FIELD RELASI)
type Jabatan struct {
	ID              uint64    `gorm:"column:idjabatan;primaryKey;autoIncrement" json:"id"`
	NamaJabatan     string    `gorm:"column:namajabatan;size:100" json:"nama_jabatan"`
	DeleteStatus    string    `gorm:"column:deletestatus;type:enum('1','2');default:'2'" json:"-"`
	
    // Foreign Key (Kunci Tamu)
	IDAnggota       *uint64   `gorm:"column:idanggota" json:"-"`
	
	DateTransaction time.Time `gorm:"column:datetransaction" json:"created_at"`

	// --- TAMBAHAN WAJIB (Agar Controller Tidak Error) ---
	// Field ini menampung data Anggota yang berelasi.
	// foreignKey:IDAnggota -> Kolom di struct ini yang jadi penghubung
	// references:ID -> Kolom di struct Anggota yang dituju
	AnggotaDetail   *Anggota  `gorm:"foreignKey:IDAnggota;references:ID" json:"anggota_detail,omitempty"`
}

func (Jabatan) TableName() string {
	return "jabatan"
}

// 3. Response Struct (Khusus untuk format JSON ke Flutter)
type JabatanResponse struct {
	ID               uint64 `json:"id"`
	NamaJabatan      string `json:"nama_jabatan"`
	NamaPejabat      string `json:"nama_pejabat"`      // Diisi dari AnggotaDetail.NamaLengkap
	NRP              string `json:"nrp"`               // Diisi dari AnggotaDetail.NRP
	TanggalPeresmian string `json:"tanggal_peresmian"` // Diisi dari DateTransaction (diformat)
}