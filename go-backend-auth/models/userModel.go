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
	Name     string `json:"name"`
	Email    string `gorm:"unique" json:"email"`
	Password string `json:"-"` 
	Role     Role   `json:"role"`
}
