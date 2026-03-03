import 'summary_item_model.dart';
import 'ringkasan_area_model.dart';
import 'harvest_model.dart';
import 'kwartal_item_model.dart';
import 'distribution_model.dart';
import 'resapan_model.dart';

class DashboardDataResponse {
  final List<SummaryItemModel> summaryData;
  final List<RingkasanAreaModel> lahanData;
  final HarvestModel? harvestData;
  final List<QuarterlyItem> quarterlyData;
  final List<DistributionModel> distributionData;
  final ResapanModel? resapanData;
  final String activeFilterLabel;

  DashboardDataResponse({
    required this.summaryData,
    required this.lahanData,
    this.harvestData,
    required this.quarterlyData,
    required this.distributionData,
    this.resapanData,
    required this.activeFilterLabel,
  });

  factory DashboardDataResponse.fromJson(Map<String, dynamic> json) {
    return DashboardDataResponse(
      summaryData: (json['summary_data'] as List? ?? [])
          .map((x) => SummaryItemModel.fromJson(x))
          .toList(),
      lahanData: (json['lahan_data'] as List? ?? [])
          .map((x) => RingkasanAreaModel.fromJson(x))
          .toList(),
      harvestData: json['harvest_data'] != null 
          ? HarvestModel.fromJson(json['harvest_data']) 
          : null,
      quarterlyData: (json['quarterly_data'] as List? ?? [])
          .map((x) => QuarterlyItem.fromJson(x))
          .toList(),
      distributionData: (json['distribution_data'] as List? ?? [])
          .map((x) => DistributionModel.fromJson(x))
          .toList(),
      resapanData: json['resapan_data'] != null 
          ? ResapanModel.fromJson(json['resapan_data']) 
          : null,
      activeFilterLabel: json['active_filter_label'] ?? "",
    );
  }
}