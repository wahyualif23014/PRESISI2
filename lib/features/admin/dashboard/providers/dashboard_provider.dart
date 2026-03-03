import 'package:flutter/material.dart';
import '../data/model/dashboard_data_response.dart';
import '../data/services/dashboard_service.dart' show DashboardService;

class DashboardProvider with ChangeNotifier {
  final DashboardService _service = DashboardService();
  
  DashboardDataResponse? _dashboardData;
  bool _isLoading = false;
  String _errorMessage = '';

  DashboardDataResponse? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchDashboard({
    String? resor,
    String? sektor,
    String? idJenisLahan,
    String? idKomoditi,
    String? tahun,
    String? kwartal,
    String? tglMulai,
    String? tglSelesai,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _service.getDashboardData(
        resor: resor,
        sektor: sektor,
        idJenisLahan: idJenisLahan,
        idKomoditi: idKomoditi,
        tahun: tahun,
        kwartal: kwartal,
        tglMulai: tglMulai,
        tglSelesai: tglSelesai,
      );

      if (result != null) {
        _dashboardData = result;
      } else {
        _errorMessage = 'Data tidak ditemukan';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}