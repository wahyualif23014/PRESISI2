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
	Name        string `json:"nama"`
	Email       string `gorm:"unique" json:"email"`
	Password    string `json:"-"`
	Role        Role   `json:"role"`
	SatuanKerja string `json:"satuan_kerja"`
}