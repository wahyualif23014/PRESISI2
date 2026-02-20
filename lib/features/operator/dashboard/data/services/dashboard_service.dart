import 'dart:async';

// Import Model Baru (DTO)
import '../model/dashboard_ui_model.dart'; 

// Import Repository Baru
import '../repo/ringkasan_area_repository.dart';
import '../repo/harvest_repository.dart';
import '../repo/kwartal_repo.dart';
import '../repo/summary_repository.dart';

class DashboardService {
  // Inisialisasi semua repository yang dibutuhkan
  final _lahanRepo = RingkasanAreaRepository();
  final _harvestRepo = HarvestRepository();
  final _quarterlyRepo = QuarterlyRepository();
  final _summaryRepo = SummaryRepository();

  Future<DashboardUiModel> getDashboardData() async {
    try {
      // Simulasi delay network
      await Future.delayed(const Duration(seconds: 1));

      // Ambil data dari masing-masing repo
      final lahanList = _lahanRepo.getRingkasanList();
      final harvest = _harvestRepo.getHarvestData();
      final quarterly = _quarterlyRepo.getQuarterlyData();
      final summary = _summaryRepo.getSummaryData();

      // Gabungkan ke dalam satu object model UI
      return DashboardUiModel(
        lahanData: lahanList as dynamic,
        harvestData: harvest,
        quarterlyData: quarterly,
        summaryData: summary,
      );
      
    } catch (e) {
      throw Exception('Gagal memuat data dashboard: $e');
    }
  }
}