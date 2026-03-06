package models

type DashboardDataResponse struct {
	ActiveFilterLabel string               `json:"active_filter_label"`
	SummaryCards      []SummaryCardModel   `json:"summary_data"`
	LahanSummary      []LahanSummaryModel  `json:"lahan_data"`
	HarvestSummary    HarvestSummaryModel  `json:"harvest_data"`
	QuarterlyData     []QuarterlyItemModel `json:"quarterly_data"`
	Distribution      []DistributionModel  `json:"distribution_data"`
	ResapanYearly     ResapanModel         `json:"resapan_data"`

	// ✅ BARU: peta penyebaran potensi lahan
	MapPotensi MapPotensiModel `json:"map_potensi"`
}

type MapPotensiModel struct {
	TotalPoints int64            `json:"total_points"`
	Points      []MapPotensiItem `json:"points"`
}

type MapPotensiItem struct {
	IDLahan     string  `json:"id_lahan"`
	Lat         float64 `json:"lat"`
	Lng         float64 `json:"lng"`
	LuasLahan   float64 `json:"luas_lahan"`
	StatusLahan string  `json:"status_lahan"`
	JenisLahan  string  `json:"jenis_lahan"`

	IDKomoditi    *string `json:"id_komoditi,omitempty"`
	NamaKomoditi  *string `json:"nama_komoditi,omitempty"`
	JenisKomoditi *string `json:"jenis_komoditi,omitempty"`

	KodeWilayah *string `json:"kode_wilayah,omitempty"`
	NamaWilayah *string `json:"nama_wilayah,omitempty"`
}

type LahanSummaryModel struct {
	Title           string            `json:"title"`
	TotalValue      float64           `json:"total_value"`
	Unit            string            `json:"unit"` // Contoh: "HA"
	BackgroundColor string            `json:"background_color"`
	IsDetailed      bool              `json:"is_detailed"`
	Items           []LahanDetailItem `json:"items"`
}

type LahanDetailItem struct {
	Label string  `json:"label"` // Diisi dari getLahanLabel(id)
	Value float64 `json:"value"` // Nilai Luas (Area)
	Count int64   `json:"count"` // Jumlah Lokasi (Distinct idlahan)
}

type SummaryCardModel struct {
	Label      string  `json:"label"`
	Value      float64 `json:"value"`
	Unit       string  `json:"unit"` // HA, LOKASI, dsb.
	Type       string  `json:"type"` // "potensi", "tanam", "panen", "lokasi"
	Percentage float64 `json:"percentage,omitempty"`
}

type HarvestSummaryModel struct {
	TotalPanen float64           `json:"total_panen_current"`
	Unit       string            `json:"unit"`
	Categories []HarvestCategory `json:"categories"`
}

type HarvestCategory struct {
	ID         string         `json:"id"`
	Label      string         `json:"label"`
	Color      string         `json:"color"`
	DataPoints []HarvestPoint `json:"data_points"`
}

type HarvestPoint struct {
	Month int     `json:"month_index"` // 1-12
	Year  int     `json:"year"`
	Value float64 `json:"value"`
}

type QuarterlyItemModel struct {
	Label  string  `json:"label"`
	Value  float64 `json:"value"`
	Unit   string  `json:"unit"`
	Period string  `json:"period"` // "KW1", "KW2", dst
}

type DistributionModel struct {
	Label string             `json:"label"`
	Total int64              `json:"total"`
	Items []DistributionItem `json:"items"`
}

type DistributionItem struct {
	Label string  `json:"label"`
	Value float64 `json:"value"`
	Color string  `json:"color"`
}

type ResapanModel struct {
	Year  string        `json:"year"`
	Total float64       `json:"total"`
	Items []ResapanItem `json:"items"`
}

type ResapanItem struct {
	Label string  `json:"label"`
	Value float64 `json:"value"`
}