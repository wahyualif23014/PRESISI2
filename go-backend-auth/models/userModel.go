package models

import (
	"time"
)


const (
	RoleAdmin  string = "1"
	RolePolres string = "2" // Asumsi level menengah
	RoleView   string = "3" // Default
)


const (
	StatusDeleted string = "1"
	StatusActive  string = "2"
)

type User struct {
	ID uint64 `gorm:"column:idanggota;primaryKey;autoIncrement" json:"id"`

	// 2. nama (Varchar 100)
	NamaLengkap string `gorm:"column:nama;size:100" json:"nama_lengkap"`

	// 3. hp (Varchar 15) -> Menggantikan NoTelp
	NoTelp string `gorm:"column:hp;size:15" json:"no_telp"`

	IDTugas string `gorm:"column:idtugas;size:13;not null" json:"id_tugas"`

	// 5. username (Longtext)
	// Menggantikan peran NRP lama sebagai login identifier
	Username string `gorm:"column:username;type:longtext" json:"username"`

	KataSandi string `gorm:"column:password;type:longtext" json:"-"`

	Role string `gorm:"column:statusadmin;type:enum('1','2','3');default:'3'" json:"role"`

	DeleteStatus string `gorm:"column:deletestatus;type:enum('1','2');default:'2'" json:"-"`

	DateTransaction time.Time `gorm:"column:datetransaction" json:"created_at"`


	IDPengguna uint64 `gorm:"column:idpengguna;not null" json:"id_pengguna"`

	JabatanID *uint64 `gorm:"column:idjabatan" json:"id_jabatan"`

	FotoProfil string `gorm:"-" json:"foto_profil,omitempty"`
}


func (User) TableName() string {
	return "anggota" 
}