package models

import "time"

type PotensiLahan struct {
	ID        uint64 `gorm:"primaryKey;column:idlahan" json:"id"`
	IDTingkat string `gorm:"column:idtingkat" json:"id_tingkat"`
	IDWilayah string `gorm:"column:idwilayah" json:"id_wilayah"`

	// --- FIELD HASIL JOIN ---
	NamaKabupaten     string `gorm:"column:nama_kabupaten;->" json:"nama_kabupaten"`
	NamaKecamatan     string `gorm:"column:nama_kecamatan;->" json:"nama_kecamatan"`
	NamaDesa          string `gorm:"column:nama_desa;->" json:"nama_desa"`
	NamaPemroses      string `gorm:"column:nama_pemroses;->" json:"nama_pemroses"` // Nama dari tabel anggota
	NamaValidator     string `gorm:"column:nama_validator;->" json:"nama_validator"`
	JenisKomoditiNama string `gorm:"column:jenis_komoditas_nama;->" json:"jenis_komoditas_nama"`
	NamaKomoditiAsli  string `gorm:"column:nama_komoditi_asli;->" json:"nama_komoditi_asli"`
	NamaPoktanAsli    string `gorm:"column:nama_poktan_asli;->" json:"nama_poktan_asli"`

	// --- DATA LAHAN ---
	IDJenisLahan int     `gorm:"column:idjenislahan" json:"id_jenis_lahan"`
	AlamatLahan  string  `gorm:"column:alamat" json:"alamat_lahan"`
	LuasLahan    float64 `gorm:"column:luaslahan" json:"luas_lahan"`

	// Permintaan 1: Keterangan ambil dari ketcp
	Keterangan string `gorm:"column:ketcp" json:"keterangan"`
	// KeteranganLain memetakan ke kolom keterangan

	// Permintaan 2: Jumlah Poktan ambil dari kolom poktan
	JumlahPoktan int `gorm:"column:poktan" json:"jumlah_poktan"`

	// --- CONTACT PERSON ---
	CPName      string `gorm:"column:cp" json:"pic_name"`
	CPPhone     string `gorm:"column:hp" json:"pic_phone"`
	PolisiName  string `gorm:"column:cppolisi" json:"police_name"`
	PolisiPhone string `gorm:"column:hppolisi" json:"police_phone"`

	// --- STATISTIK ---
	JumlahPetani int `gorm:"column:jmlsantri" json:"jumlah_petani"`
	// Keterangan memetakan ke kolom ketcp

	KeteranganLain string `gorm:"column:keterangan" json:"keterangan_lain"`
	Latitude       string `gorm:"column:lat" json:"latitude"`
	Longitude      string `gorm:"column:longi" json:"longitude"`

	Foto        string `gorm:"column:dokumentasi" json:"foto_lahan"`
	StatusLahan string `gorm:"column:statuslahan" json:"status_validasi"`

	// --- AUDIT TRAIL (Permintaan 3: editoleh & tgledit) ---
	EditOleh        string    `gorm:"column:editoleh" json:"editoleh"` // ID Anggota
	TglEdit         string    `gorm:"column:tgledit" json:"tgl_edit"`  // Waktu Edit
	ValidOleh       string    `gorm:"column:validoleh" json:"validoleh"`
	TglValid        string    `gorm:"column:tglvalid" json:"tgl_valid"`
	DateTransaction time.Time `gorm:"column:datetransaction" json:"tgl_proses"`
}

func (PotensiLahan) TableName() string {
	return "lahan"
}
