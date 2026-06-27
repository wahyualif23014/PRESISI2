package models

type Lahan struct {
	IDLahan         int64   `gorm:"primaryKey;column:id_lahan" json:"id_lahan"`
	IDJenisLahan    int     `gorm:"column:id_jenis_lahan" json:"id_jenis_lahan"`
	IDKomoditi      int     `gorm:"column:id_komoditi" json:"id_komoditi"`
	IDTingkat       string  `gorm:"column:id_tingkat" json:"id_tingkat"`
	IDWilayah       string  `gorm:"column:id_wilayah" json:"id_wilayah"`
	LuasLahan       float64 `gorm:"column:luas_lahan" json:"luas_l_ahan"`
	StatusLahan     string  `gorm:"column:status_lahan" json:"status_lahan"`
	DeleteStatus    string  `gorm:"column:deletestatus" json:"delete_status"`
	DateTransaction string  `gorm:"column:datetransaction" json:"date_transaction"`
}

// TableName menentukan nama tabel secara eksplisit agar GORM tidak melakukan pluralisasi otomatis
func (Lahan) TableName() string {
	return "lahan"
}