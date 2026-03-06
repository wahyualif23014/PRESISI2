package models

type Lahan struct {
	IDLahan         int64   `gorm:"primaryKey;column:idlahan" json:"id_lahan"`
	IDJenisLahan    int     `gorm:"column:idjenislahan" json:"id_jenis_lahan"`
	IDKomoditi      int     `gorm:"column:idkomoditi" json:"id_komoditi"`
	IDWilayah       string  `gorm:"column:idwilayah" json:"id_wilayah"`
	LuasLahan       float64 `gorm:"column:luaslahan" json:"luas_lahan"`
	StatusLahan     string  `gorm:"column:statuslahan" json:"status_lahan"`
	DeleteStatus    string  `gorm:"column:deletestatus" json:"delete_status"`
	DateTransaction string  `gorm:"column:datetransaction" json:"date_transaction"`
}

// TableName menentukan nama tabel secara eksplisit agar GORM tidak melakukan pluralisasi otomatis
func (Lahan) TableName() string {
	return "lahan"
}