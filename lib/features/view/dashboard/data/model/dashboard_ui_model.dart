import 'ringkasan_area_model.dart';
import 'harvest_model.dart';
import 'kwartal_item_model.dart';
import 'summary_item_model.dart';
// import 'distribution_model.dart'; // Jika ada
// import 'resapan_model.dart';      // Jika ada

class DashboardUiModel {
  final List<RingkasanAreaModel> lahanData;
  final HarvestModel harvestData;
  final List<QuarterlyItem> quarterlyData;
  final List<SummaryItemModel> summaryData; // Pakai SummaryItemModel baru

  DashboardUiModel({
    required this.lahanData,
    required this.harvestData,
    required this.quarterlyData,
    required this.summaryData,
  });
}