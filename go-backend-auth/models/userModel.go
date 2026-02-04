package models

import (
	"gorm.io/gorm"
)

type Role string

const (
	RoleAdmin  Role = "admin"
	RoleView   Role = "view"
	RolePolres Role = "polres"
	RolePolsek Role = "polsek"
)

type User struct {
	gorm.Model
	NamaLengkap string `json:"nama_lengkap"`
	NRP         string `gorm:"unique;not null" json:"nrp"`
	Jabatan     string `json:"jabatan"`
	Password    string `json:"-"`
	Role        Role   `json:"role"`
	FotoProfil  string `json:"foto_profil"`
	
	// UPDATE DI SINI:
	// Kita tambahkan tag gorm type:enum agar sinkron dengan database
	Status      string `json:"status" gorm:"type:enum('active', 'pending');default:'pending'"` 
}