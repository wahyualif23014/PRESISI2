package models

type DashboardDataResponse struct {
	SummaryCards []SummaryCardModel `json:"summary_data"`

	LahanSummary []LahanSummaryModel `json:"lahan_data"`

	HarvestSummary HarvestSummaryModel `json:"harvest_data"`

	QuarterlyData []QuarterlyItemModel `json:"quarterly_data"`

	Distribution []DistributionModel `json:"distribution_data"`

	ResapanYearly ResapanModel `json:"resapan_data"`

	ActiveFilterLabel string `json:"active_filter_label"`
}

type LahanSummaryModel struct {
	Title           string            `json:"title"`
	TotalValue      float64           `json:"total_value"`
	BackgroundColor string            `json:"background_color"`
	IsDetailed      bool              `json:"is_detailed"`
	Items           []LahanDetailItem `json:"items"`
}

type LahanDetailItem struct {
	Category string  `json:"category"`
	Label    string  `json:"label"`
	Value    float64 `json:"value"`
	Count    int64   `json:"count"` // Tambahkan jumlah lokasi per sub-kategori
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
	Value  float64 `json:"value"`
	Unit   string  `json:"unit"`
	Label  string  `json:"label"`
	Period string  `json:"period"` // "KW1", "KW2", dst
}

type SummaryCardModel struct {
	Label      string  `json:"label"`
	Value      float64 `json:"value"`
	Unit       string  `json:"unit"`
	Type       string  `json:"type"` // "potensi", "validasi", "empty_wilayah"
	Percentage float64 `json:"percentage,omitempty"`
}

type DistributionModel struct {
	Label string             `json:"label"`
	Total int64              `json:"total"` // Gunakan int64 untuk hasil Count DB
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
