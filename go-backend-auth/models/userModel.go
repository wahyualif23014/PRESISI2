package models

import (
	"gorm.io/gorm"
)

// Definisi Role sebagai ENUM
type Role string

const (
	RoleAdmin  Role = "admin"
	RoleView   Role = "view"   // Default untuk user baru
	RolePolres Role = "polres"
	RolePolsek Role = "polsek"
)

type User struct {
	gorm.Model
	NamaLengkap string `json:"nama_lengkap"`
	NRP         string `gorm:"unique;not null" json:"nrp"`
	Jabatan     string `json:"jabatan"`
	KataSandi    string `json:"-"` // Kata Sandi tidak dikirim balik ke JSON response

	// Role Enum
	Role Role `json:"role" gorm:"type:enum('admin','view','polres','polsek');default:'view'"`

	// Profil Tambahan
	FotoProfil string `json:"foto_profil"`
	NoTelp     string `json:"no_telp"` // Tambahan baru (String/Varchar)
}