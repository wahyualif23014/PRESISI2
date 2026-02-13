package models

import (
	"time"
)

type PotensiLahan struct {
	ID        uint   `gorm:"primaryKey;column:idlahan" json:"id"`
	IdWilayah string `gorm:"column:idwilayah" json:"id_wilayah"`

	// --- FIELD BARU (HASIL JOIN) ---
	// Field ini tidak ada di tabel 'lahan', tapi akan diisi lewat Query JOIN
	NamaKabupaten string `gorm:"->" json:"nama_kabupaten"`
	NamaKecamatan string `gorm:"->" json:"nama_kecamatan"`
	NamaDesa      string `gorm:"->" json:"nama_desa"`

	IdJenisLahan int     `gorm:"column:idjenislahan" json:"id_jenis_lahan"`
	Alamat       string  `gorm:"column:alamat" json:"alamat_lahan"`
	LuasLahan    float64 `gorm:"column:luaslahan" json:"luas_lahan"`

	NamaPoktan  string `gorm:"column:poktan" json:"keterangan"`
	CPName      string `gorm:"column:cp" json:"pic_name"`
	CPPhone     string `gorm:"column:hp" json:"pic_phone"`
	PolisiName  string `gorm:"column:cppolisi" json:"police_name"`
	PolisiPhone string `gorm:"column:hppolisi" json:"police_phone"`

	JumlahPoktan   int    `gorm:"column:jumlah_poktan;default:0" json:"jumlah_poktan"`
	JumlahPetani   int    `gorm:"column:jumlah_petani;default:0" json:"jumlah_petani"`
	KeteranganLain string `gorm:"column:keterangan_lain" json:"keterangan_lain"`

	Foto        string `gorm:"column:dokumentasi" json:"foto_lahan"`
	StatusLahan string `gorm:"column:statuslahan" json:"status_validasi"`
	IdKomoditi  int    `gorm:"column:idkomoditi" json:"id_komoditi"`

	DateTransaction time.Time `gorm:"column:datetransaction" json:"tgl_proses"`
	DiprosesOleh    string    `gorm:"column:diproses_oleh" json:"diproses_oleh"`
	DivalidasiOleh  string    `gorm:"column:divalidasi_oleh" json:"divalidasi_oleh"`
	TglValidasi     string    `gorm:"column:tgl_validasi" json:"tgl_validasi"`
}

func (PotensiLahan) TableName() string {
	return "lahan"
}