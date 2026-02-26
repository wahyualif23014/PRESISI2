package models

import (
	"time"
)

type PotensiLahan struct {
	ID           uint64 `gorm:"primaryKey;column:idlahan" json:"id"`
	IDTingkat    string `gorm:"column:idtingkat" json:"id_tingkat"`
	IDWilayah    string `gorm:"column:idwilayah" json:"id_wilayah"`
	IDJenisLahan int    `gorm:"column:idjenislahan" json:"id_jenis_lahan"`
	Alamat       string `gorm:"column:alamat" json:"alamat_lahan"`
	
	Longitude    float64 `gorm:"column:longi" json:"longitude"`
	Latitude     float64 `gorm:"column:lat" json:"latitude"`
	
	PoktanCount  int    `gorm:"column:poktan" json:"jumlah_poktan"` 
	CP           string `gorm:"column:cp" json:"pic_name"`
	HP           string `gorm:"column:hp" json:"pic_phone"`
	LuasLahan    float64 `gorm:"column:luaslahan" json:"luas_lahan"`
	
	// SINKRON: json:"keterangan_lain" untuk kolom ketlahan (ENUM '1','2','3')
	KetLahan     string `gorm:"column:ketlahan" json:"keterangan_lain"` 
	
	SK           string `gorm:"column:sk" json:"sk_lahan"`
	Lembaga      string `gorm:"column:lembaga" json:"lembaga"`
	CPPolisi     string `gorm:"column:cppolisi" json:"police_name"`
	HPPolisi     string `gorm:"column:hppolisi" json:"police_phone"`
	Keterangan   string `gorm:"column:keterangan" json:"keterangan"`

	SumberData      string    `gorm:"column:sumberdata" json:"sumber_data"`
	Foto            string    `gorm:"column:dokumentasi" json:"foto_lahan"` 
	JmlSantri       int       `gorm:"column:jmlsantri" json:"jumlah_petani"`
	DateTransaction time.Time `gorm:"column:datetransaction" json:"tgl_proses"`
	
	// ENUM Guard: json:"delete_status" untuk kolom deletestatus
	DeleteStatus    string    `gorm:"column:deletestatus" json:"delete_status"`
	
	IDAnggota       uint64    `gorm:"column:idanggota" json:"id_anggota"`
	ConLahan        uint64    `gorm:"column:conlahan" json:"con_lahan"`
	KetCP           string    `gorm:"column:ketcp" json:"ket_cp"`
	
	// SINKRON: json:"status_validasi" untuk kolom statuslahan (ENUM '1','2','3','4')
	StatusLahan     string     `gorm:"column:statuslahan" json:"status_validasi"`
	
	StatusPakai     string     `gorm:"column:statuspakai" json:"status_pakai"`
	SuratEdit       string     `gorm:"column:suratedit" json:"surat_edit"`
	EditOleh        uint64     `gorm:"column:editoleh" json:"edit_oleh"`
	TglEdit         *time.Time `gorm:"column:tgledit" json:"tgl_edit"`
	ValidOleh       uint64     `gorm:"column:validoleh" json:"valid_oleh"`
	TglValid        *time.Time `gorm:"column:tglvalid" json:"tgl_validasi"`
	TahunLahan      string     `gorm:"column:tahunlahan" json:"tahun_lahan"`
	IDKomoditi      uint64     `gorm:"column:idkomoditi" json:"id_komoditi"`
	StatusAktif     string     `gorm:"column:statusaktif" json:"status_aktif"`

	// Virtual Fields (Read Only)
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