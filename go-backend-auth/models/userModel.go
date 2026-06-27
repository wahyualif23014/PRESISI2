package models

import (
	"time"
)

const (
	RoleAdmin    string = "admin"
	RoleOperator string = "operator"
	RoleView     string = "view"
)

const (
	StatusDeleted string = "1"
	StatusActive  string = "2"
)

type User struct {
	ID          uint64 `gorm:"column:id_anggota;primaryKey;autoIncrement:true" json:"id"`
	NamaLengkap string `gorm:"column:nama_anggota;size:100" json:"nama_lengkap"`
	NoTelp      string `gorm:"column:no_telp_anggota;size:20" json:"no_telp"`
	IDTugas     string `gorm:"column:id_tugas;size:13;not null" json:"id_tugas"`

	Username        string    `gorm:"column:username;type:longtext" json:"nrp"`
	KataSandi       string    `gorm:"column:password;type:longtext" json:"-"`
	Role            string    `gorm:"column:role;type:enum('admin','operator','view');default:'view'" json:"role"`
	DeleteStatus    string    `gorm:"column:deletestatus;type:enum('1','2');default:'2'" json:"-"`
	DateTransaction time.Time `gorm:"column:datetransaction;autoCreateTime" json:"created_at"`
	TingkatDetail   *Tingkat  `gorm:"foreignKey:IDTugas;references:Kode" json:"tingkat_detail,omitempty"`

	JabatanID uint64  `gorm:"column:id_jabatan" json:"id_jabatan"`
	JabatanDetail   *Jabatan `gorm:"foreignKey:JabatanID;references:ID" json:"jabatan,omitempty"`
}

func (User) TableName() string {
	return "anggota"
}
