package models

import (
	"time"
)

type PotensiLahan struct {
	// --- KOLOM UTAMA (image_37bb70.png) ---
	ID           uint64  `gorm:"primaryKey;column:idlahan;autoIncrement" json:"id"`
	IDTingkat    string  `gorm:"column:idtingkat;type:varchar(13)" json:"id_tingkat"`
	IDWilayah    string  `gorm:"column:idwilayah;type:varchar(13)" json:"id_wilayah"`
	IDJenisLahan int     `gorm:"column:idjenislahan" json:"id_jenis_lahan"`
	Alamat       string  `gorm:"column:alamat;type:longtext" json:"alamat_lahan"`
	Longitude    float64 `gorm:"column:longi" json:"longitude"` // DB varchar(25), GORM akan otomatis konversi
	Latitude     float64 `gorm:"column:lat" json:"latitude"`   // DB varchar(25), GORM akan otomatis konversi
	PoktanCount  int     `gorm:"column:poktan" json:"jumlah_poktan"`
	CP           string  `gorm:"column:cp;type:varchar(100)" json:"pic_name"`
	HP           string  `gorm:"column:hp;type:varchar(15)" json:"pic_phone"`
	LuasLahan    float64 `gorm:"column:luaslahan" json:"luas_lahan"` // DB decimal(10,2)
	KetLahan     string  `gorm:"column:ketlahan" json:"keterangan_lain"` // ENUM('1','2','3')
	SK           string  `gorm:"column:sk;type:varchar(20)" json:"sk_lahan"`
	Lembaga      string  `gorm:"column:lembaga;type:varchar(50)" json:"lembaga"`
	CPPolisi     string  `gorm:"column:cppolisi;type:varchar(100)" json:"police_name"`
	HPPolisi     string  `gorm:"column:hppolisi;type:varchar(15)" json:"police_phone"`
	Keterangan   string  `gorm:"column:keterangan;type:longtext" json:"keterangan"`

	// --- KOLOM LANJUTAN (image_37bb4f.png & image_c09d75.png) ---
	SumberData      string     `gorm:"column:sumberdata;type:varchar(100)" json:"sumber_data"`
	Foto            string     `gorm:"column:dokumentasi;type:longtext" json:"foto_lahan"`
	JmlSantri       int        `gorm:"column:jmlsantri" json:"jumlah_petani"`
	DateTransaction time.Time  `gorm:"column:datetransaction" json:"tgl_proses"`
	DeleteStatus    string     `gorm:"column:deletestatus" json:"delete_status"` // ENUM('1','2')
	IDAnggota       uint64     `gorm:"column:idanggota" json:"id_anggota"`
	ConLahan        uint64     `gorm:"column:conlahan" json:"con_lahan"`
	KetCP           string     `gorm:"column:ketcp;type:text" json:"ket_cp"`
	StatusLahan     string     `gorm:"column:statuslahan" json:"status_validasi"` // ENUM('1','2','3','4')
	StatusPakai     string     `gorm:"column:statuspakai" json:"status_pakai"`    // ENUM('1','2')
	SuratEdit       string     `gorm:"column:suratedit;type:text" json:"surat_edit"`
	EditOleh        uint64     `gorm:"column:editoleh" json:"edit_oleh"`
	TglEdit         *time.Time `gorm:"column:tgledit" json:"tgl_edit"`
	ValidOleh       uint64     `gorm:"column:validoleh" json:"valid_oleh"`
	TglValid        *time.Time `gorm:"column:tglvalid" json:"tgl_validasi"`
	TahunLahan      string     `gorm:"column:tahunlahan;type:varchar(4)" json:"tahun_lahan"`
	IDKomoditi      uint64     `gorm:"column:idkomoditi" json:"id_komoditi"`
	StatusAktif     string     `gorm:"column:statusaktif" json:"status_aktif"` // ENUM('1','2')

	// --- VIRTUAL FIELDS (JOIN) ---
	NamaKabupaten     string `gorm:"->" json:"nama_kabupaten"`
	NamaKecamatan     string `gorm:"->" json:"nama_kecamatan"`
	NamaDesa          string `gorm:"->" json:"nama_desa"`
	NamaPemroses      string `gorm:"->" json:"nama_pemroses"`
	NamaValidator     string `gorm:"->" json:"nama_validator"`
	JenisKomoditiNama string `gorm:"->" json:"jenis_komoditas_nama"`
	NamaKomoditiAsli  string `gorm:"->" json:"nama_komoditi_asli"`
	
	ImageURL          string `gorm:"-" json:"image_url"`
}

func (PotensiLahan) TableName() string {
	return "lahan"
}