import 'package:flutter/material.dart';
import '../data/model/dashboard_data_response.dart';
import '../data/services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _service = DashboardService();

  DashboardDataResponse? _dashboardData;
  bool _isLoading = false;
  String _errorMessage = '';

  DashboardDataResponse? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // ==========================
  // ✅ Map Potensi state
  // ==========================
  MapPotensiModel? _mapPotensi;
  bool _isMapLoading = false;
  String _mapErrorMessage = '';

  MapPotensiModel? get mapPotensi => _mapPotensi;
  bool get isMapLoading => _isMapLoading;
  String get mapErrorMessage => _mapErrorMessage;

  // ==========================
  // Filter state
  // ==========================
  List<String> _jenisKomoditiList = [];
  List<String> get jenisKomoditiList => _jenisKomoditiList;

  List<KomoditiOption> _komoditiList = [];
  List<KomoditiOption> get komoditiList => _komoditiList;

  String? _selectedJenisKomoditi;
  String? get selectedJenisKomoditi => _selectedJenisKomoditi;

  String? _selectedKomoditiId;
  String? get selectedKomoditiId => _selectedKomoditiId;

  // ==========================
  // Init filter (panggil sekali)
  // ==========================
  Future<void> initFilters() async {
    try {
      _jenisKomoditiList = await _service.getJenisKomoditi();
      notifyListeners();
    } catch (e) {
      debugPrint("InitFilters error: $e");
    }
  }

  Future<void> selectJenisKomoditi(String? jenis) async {
    final normalized =
        (jenis == null || jenis.trim().isEmpty) ? null : jenis.trim();
    if (_selectedJenisKomoditi == normalized) return;

    _selectedJenisKomoditi = normalized;
    _selectedKomoditiId = null;
    _komoditiList = [];
    notifyListeners();

    if (_selectedJenisKomoditi != null) {
      try {
        _komoditiList =
            await _service.getKomoditiByJenis(_selectedJenisKomoditi!);
      } catch (e) {
        debugPrint("selectJenisKomoditi error: $e");
      }
      notifyListeners();
    }

    await fetchDashboard();
    await fetchMapPotensi();
  }

  Future<void> selectKomoditi(String? idKomoditi) async {
    final normalized = (idKomoditi == null || idKomoditi.trim().isEmpty)
        ? null
        : idKomoditi.trim();
    if (_selectedKomoditiId == normalized) return;

    _selectedKomoditiId = normalized;
    notifyListeners();

    await fetchDashboard();
    await fetchMapPotensi();
  }

  // ==========================
  // Fetch Dashboard
  // ==========================
  Future<void> fetchDashboard({
    String? resor,
    String? sektor,
    String? idJenisLahan,
    String? tglMulai,
    String? tglSelesai,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    _dashboardData = null;
    notifyListeners();

    try {
      final result = await _service.getDashboardData(
        resor: resor,
        sektor: sektor,
        idJenisLahan: idJenisLahan,
        jenisKomoditi: _selectedJenisKomoditi,
        idKomoditi: _selectedKomoditiId,
        tglMulai: tglMulai,
        tglSelesai: tglSelesai,
      );

      if (result != null) {
        _dashboardData = result;
      } else {
        _errorMessage = 'Gagal mendapatkan data dashboard';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan';
      debugPrint("Dashboard Provider Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================
  // ✅ Fetch Map Potensi
  // ==========================
  Future<void> fetchMapPotensi({
    String? resor,
    String? sektor,
    String? idJenisLahan,
  }) async {
    _isMapLoading = true;
    _mapErrorMessage = '';
    _mapPotensi = null;
    notifyListeners();

    try {
      final result = await _service.getMapPotensi(
        resor: resor,
        sektor: sektor,
        idJenisLahan: idJenisLahan,
        jenisKomoditi: _selectedJenisKomoditi,
        idKomoditi: _selectedKomoditiId,
      );

      if (result != null) {
        _mapPotensi = result;
      } else {
        _mapErrorMessage = 'Gagal mendapatkan data peta potensi lahan';
      }
    } catch (e) {
      _mapErrorMessage = 'Terjadi kesalahan jaringan';
      debugPrint("Map Potensi Provider Error: $e");
    } finally {
      _isMapLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _dashboardData = null;
    _mapPotensi = null;
    notifyListeners();
  }
}