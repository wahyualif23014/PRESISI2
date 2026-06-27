package models

import "time"

type PotensiLahan struct {
	ID        uint64 `gorm:"primaryKey;column:id_lahan" json:"id"`
	IDTingkat string `gorm:"column:id_tingkat" json:"id_tingkat"`
	IDWilayah string `gorm:"column:id_wilayah" json:"id_wilayah"`

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
	IDJenisLahan int     `gorm:"column:id_jenis_lahan" json:"id_jenis_lahan"`
	IDKomoditi   int     `gorm:"column:id_komoditi" json:"id_komoditi"` // Menambahkan field ID Komoditi
	AlamatLahan  string  `gorm:"column:alamat_lahan" json:"alamat_lahan"`
	LuasLahan    float64 `gorm:"column:luas_lahan" json:"luas_lahan"`

	// Keterangan ambil dari keterangan_lahan
	Keterangan string `gorm:"column:keterangan_lahan" json:"keterangan"`

	// Jumlah Poktan ambil dari kolom poktan
	JumlahPoktan int `gorm:"column:poktan" json:"jumlah_poktan"`

	// --- CONTACT PERSON ---
	CPName      string `gorm:"column:cp_lahan" json:"pic_name"`
	CPPhone     string `gorm:"column:no_cp_lahan" json:"pic_phone"`
	PolisiName  string `gorm:"column:cp_polisi" json:"police_name"` // Diisi dengan nama Polisi
	PolisiPhone string `gorm:"column:no_cp_polisi" json:"police_phone"`

	// --- STATISTIK ---
	JumlahPetani int `gorm:"column:jml_petani" json:"jumlah_petani"`

	KeteranganLain string `gorm:"column:keterangan_lahan" json:"keterangan_lain"`
	Latitude       string `gorm:"column:latitude" json:"latitude"`
	Longitude      string `gorm:"column:longitude" json:"longitude"`

	Foto        string `gorm:"column:dokumentasi_lahan" json:"foto_lahan"`
	StatusLahan string `gorm:"column:status_lahan" json:"status_validasi"`

	// --- AUDIT TRAIL ---
	IDAnggota       *int      `gorm:"column:id_anggota" json:"id_anggota"` // Pointer because it can be null
	EditOleh        string    `gorm:"column:edit_oleh" json:"editoleh"`    // ID/Username Anggota penginput
	TglEdit         string    `gorm:"column:tgl_edit" json:"tgl_edit"`
	ValidOleh       string    `gorm:"column:valid_oleh" json:"validoleh"`
	TglValid        string    `gorm:"column:tgl_valid" json:"tgl_valid"`
	DateTransaction time.Time `gorm:"column:datetransaction" json:"tgl_proses"`
}

func (PotensiLahan) TableName() string {
	return "lahan"
}
