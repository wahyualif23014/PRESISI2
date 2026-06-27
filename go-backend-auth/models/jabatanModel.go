package models

import (
	"time"
)

type Jabatan struct {
	ID              uint64    `gorm:"column:id_jabatan;primaryKey;autoIncrement" json:"id"`
	NamaJabatan     string    `gorm:"column:nama_jabatan;size:100" json:"nama_jabatan"`
	DeleteStatus    string    `gorm:"column:deletestatus;type:enum('1','2');default:'2'" json:"-"`
	DateTransaction time.Time `gorm:"column:datetransaction;autoCreateTime" json:"created_at"`
}

func (Jabatan) TableName() string {
	return "jabatan"
}