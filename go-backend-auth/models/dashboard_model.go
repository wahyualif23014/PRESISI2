package models

type DashboardDataResponse struct {
	LahanSummary    []LahanSummaryModel    `json:"lahan_data"`
	HarvestSummary  HarvestSummaryModel    `json:"harvest_data"`
	QuarterlyData   []QuarterlyItemModel   `json:"quarterly_data"`
	SummaryCards    []SummaryCardModel     `json:"summary_data"`
	Distribution    []DistributionModel    `json:"distribution_data"`
	ResapanYearly   ResapanModel           `json:"resapan_data"`
}

type LahanSummaryModel struct {
	Title           string               `json:"title"`
	TotalValue      float64              `json:"total_value"`
	BackgroundColor string               `json:"background_color"`
	IsDetailed      bool                 `json:"is_detailed"`
	Items           []LahanDetailItem    `json:"items"`
}

type LahanDetailItem struct {
	Category string  `json:"category"`
	Label    string  `json:"label"`
	Value    float64 `json:"value"`
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
	Month int     `json:"month_index"`
	Value float64 `json:"value"`
}

type QuarterlyItemModel struct {
	Value  float64 `json:"value"`
	Unit   string  `json:"unit"`
	Label  string  `json:"label"`
	Period string  `json:"period"`
}

type SummaryCardModel struct {
	Label string  `json:"label"`
	Value float64 `json:"value"`
	Unit  string  `json:"unit"`
	Type  string  `json:"type"`
}

type DistributionModel struct {
	Label string             `json:"label"`
	Total int                `json:"total"`
	Items []DistributionItem `json:"items"`
}

type DistributionItem struct {
	Value float64 `json:"value"`
	Color string  `json:"color"`
}

type ResapanModel struct {
	Year  string        `json:"year"`
	Total int           `json:"total"`
	Items []ResapanItem `json:"items"`
}

type ResapanItem struct {
	Label string `json:"label"`
	Value int    `json:"value"`
}