package models

import (
	"gorm.io/gorm"
)

// Definisi Role sebagai ENUM
type Role string

const (
	RoleAdmin  Role = "admin"
	RoleView   Role = "view" // Default untuk user baru (pengganti pending)
	RolePolres Role = "polres"
	RolePolsek Role = "polsek"
)

type User struct {
	gorm.Model
	NamaLengkap string `json:"nama_lengkap"`
	NRP         string `gorm:"unique;not null" json:"nrp"`
	Jabatan     string `json:"jabatan"`
	Password    string `json:"-"`

	Role Role `json:"role" gorm:"type:enum('admin','view','polres','polsek');default:'view'"`

	FotoProfil string `json:"foto_profil"`
}
