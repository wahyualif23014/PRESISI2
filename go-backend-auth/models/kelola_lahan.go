package models

import (
	"time"

	"gorm.io/gorm"
)

type KelolaLahanSummary struct {
	TotalPotensiLahan  float64 `json:"total_potensi"`
	TotalTanamLahan    float64 `json:"total_tanam"`
	TotalPanenLahanHa  float64 `json:"total_panen_ha"`
	TotalPanenLahanTon float64 `json:"total_panen_ton"`
	TotalSerapanTon    float64 `json:"total_serapan"`
}

type KelolaLahanItem struct {
	ID             string `json:"id"`
	RegionGroup    string `json:"region_group"`
	SubRegionGroup string `json:"sub_region_group"`

	PicName       string  `json:"pic_name"`
	PicPhone      string  `json:"pic_phone"`
	LandArea      float64 `json:"land_area"`
	LuasTanam     float64 `json:"luas_tanam"`
	EstPanen      string  `json:"est_panen"`
	LuasPanen     float64 `json:"luas_panen"`
	BeratPanen    float64 `json:"berat_panen"`
	Serapan       float64 `json:"serapan"`
	PoliceName    string  `json:"police_name"`
	PolicePhone   string  `json:"police_phone"`
	IsValidated   bool    `json:"is_validated"`
	Status        string  `json:"status"`
	StatusColor   string  `json:"status_color"`
	KategoriLahan string  `json:"kategori_lahan"`

	PolresName     string `json:"polres_name"`
	PolsekName     string `json:"polsek_name"`
	JenisLahanName string `json:"jenis_lahan_name"`
	Keterangan     string `json:"keterangan"`
	JmlPoktan      int    `json:"jml_poktan"`
	JmlPetani      int    `json:"jml_petani"`
	KomoditiName   string `json:"komoditi_name"`
	AlamatLahan    string `json:"alamat_lahan"`
	WilayahLahan   string `json:"wilayah_lahan"`

	IdTanam          string  `json:"id_tanam"`
	TglTanam         string  `json:"tgl_tanam"`
	LuasTanamDetail  float64 `json:"luas_tanam_detail"`
	JenisBibit       string  `json:"jenis_bibit"`
	KebutuhanBibit   float64 `json:"kebutuhan_bibit"`
	EstAwalPanen     string  `json:"est_awal_panen"`
	EstAkhirPanen    string  `json:"est_akhir_panen"`
	DokumenPendukung string  `json:"dokumen_pendukung"`
	KeteranganTanam  string  `json:"keterangan_tanam"`
}

type KelolaLahan struct {
	gorm.Model
	// ... field Anda yang sudah ada sebelumnya (PolisiPenggerak, Alamat, dll) ...

	// Tambahan field untuk fitur Validasi
	StatusValidasi  string     `gorm:"type:varchar(50);default:'BELUM TERVALIDASI'"`
	DivalidasiOleh  string     `gorm:"type:varchar(100)"` // Menyimpan nama atau pangkat personel
	TanggalValidasi *time.Time // Menggunakan pointer (*) agar nilainya bisa NULL di database jika belum divalidasi
}
