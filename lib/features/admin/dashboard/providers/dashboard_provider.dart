import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/wilayah_distribution_model.dart' show WilayahDistributionModel;
import 'package:flutter/material.dart';

import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/dashboard_data_response.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/resapan_model.dart'
    show ResapanModel;

import '../data/services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _service = DashboardService();

  // =====================================================
  // DASHBOARD STATE
  // =====================================================

  DashboardDataResponse? _dashboardData;
  bool _isLoading = false;
  String _errorMessage = '';

  DashboardDataResponse? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // =====================================================
  // MAP POTENSI STATE
  // =====================================================

  MapPotensiModel? _mapPotensi;
  bool _isMapLoading = false;
  String _mapErrorMessage = '';

  MapPotensiModel? get mapPotensi => _mapPotensi;
  bool get isMapLoading => _isMapLoading;
  String get mapErrorMessage => _mapErrorMessage;

  // =====================================================
  // RESAPAN STATE
  // =====================================================

  ResapanModel? _resapanData;
  bool _isResapanLoading = false;
  String _resapanError = '';

  ResapanModel? get resapanData => _resapanData;
  bool get isResapanLoading => _isResapanLoading;
  String get resapanError => _resapanError;

  // =====================================================
  // WILAYAH DISTRIBUTION STATE (BARU)
  // =====================================================

  List<WilayahDistributionModel> _wilayahDistribution = [];
  bool _isWilayahLoading = false;
  String _wilayahError = '';

  List<WilayahDistributionModel> get wilayahDistribution =>
      _wilayahDistribution;

  bool get isWilayahLoading => _isWilayahLoading;

  String get wilayahError => _wilayahError;

  // =====================================================
  // FILTER STATE
  // =====================================================

  List<String> _jenisKomoditiList = [];
  List<String> get jenisKomoditiList => _jenisKomoditiList;

  List<KomoditiOption> _komoditiList = [];
  List<KomoditiOption> get komoditiList => _komoditiList;

  String? _selectedJenisKomoditi;
  String? get selectedJenisKomoditi => _selectedJenisKomoditi;

  String? _selectedKomoditiId;
  String? get selectedKomoditiId => _selectedKomoditiId;

  String? _selectedResor;
  String? get selectedResor => _selectedResor;

  String? _selectedSektor;
  String? get selectedSektor => _selectedSektor;

  String? _selectedJenisLahan;
  String? get selectedJenisLahan => _selectedJenisLahan;

  // =====================================================
  // INIT FILTER
  // =====================================================

  Future<void> initFilters() async {
    try {
      _jenisKomoditiList = await _service.getJenisKomoditi();
      notifyListeners();
    } catch (e) {
      debugPrint("InitFilters error: $e");
    }
  }

  // =====================================================
  // FILTER UPDATE METHODS
  // =====================================================

  Future<void> updateResor(String? value) async {
    if (_selectedResor == value) return;

    _selectedResor = value;

    await refreshAllData();
  }

  Future<void> updateSektor(String? value) async {
    if (_selectedSektor == value) return;

    _selectedSektor = value;

    await refreshAllData();
  }

  Future<void> updateJenisLahan(String? value) async {
    if (_selectedJenisLahan == value) return;

    _selectedJenisLahan = value;

    await refreshAllData();
  }

  // =====================================================
  // SELECT JENIS KOMODITI
  // =====================================================

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
        _komoditiList = await _service.getKomoditiByJenis(
          _selectedJenisKomoditi!,
        );
      } catch (e) {
        debugPrint("selectJenisKomoditi error: $e");
      }
    }

    notifyListeners();

    await refreshAllData();
  }

  // =====================================================
  // SELECT KOMODITI
  // =====================================================

  Future<void> selectKomoditi(String? idKomoditi) async {
    final normalized =
        (idKomoditi == null || idKomoditi.trim().isEmpty)
            ? null
            : idKomoditi.trim();

    if (_selectedKomoditiId == normalized) return;

    _selectedKomoditiId = normalized;

    notifyListeners();

    await refreshAllData();
  }

  // =====================================================
  // REFRESH ALL DATA
  // =====================================================

  Future<void> refreshAllData({String? tglMulai, String? tglSelesai}) async {
    await Future.wait([
      fetchDashboard(
        resor: _selectedResor,
        sektor: _selectedSektor,
        idJenisLahan: _selectedJenisLahan,
        tglMulai: tglMulai,
        tglSelesai: tglSelesai,
      ),
      fetchMapPotensi(
        resor: _selectedResor,
        sektor: _selectedSektor,
        idJenisLahan: _selectedJenisLahan,
      ),
      fetchResapanSummary(),
      fetchWilayahDistribution(), // ✅ BARU
    ]);
  }

  // =====================================================
  // FETCH DASHBOARD
  // =====================================================

  Future<void> fetchDashboard({
    String? resor,
    String? sektor,
    String? idJenisLahan,
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
    }

    _isLoading = false;
    notifyListeners();
  }

  // =====================================================
  // FETCH MAP POTENSI
  // =====================================================

  Future<void> fetchMapPotensi({
    String? resor,
    String? sektor,
    String? idJenisLahan,
  }) async {
    _isMapLoading = true;
    _mapErrorMessage = '';

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
    }

    _isMapLoading = false;
    notifyListeners();
  }

  // =====================================================
  // FETCH RESAPAN SUMMARY
  // =====================================================

  Future<void> fetchResapanSummary() async {
    _isResapanLoading = true;
    _resapanError = '';

    notifyListeners();

    try {
      final result = await _service.getResapanSummary(
        idKomoditi: _selectedKomoditiId,
      );

      if (result != null) {
        _resapanData = result;
      } else {
        _resapanError = 'Gagal mendapatkan data resapan';
      }
    } catch (e) {
      _resapanError = 'Terjadi kesalahan jaringan';
      debugPrint("Resapan Provider Error: $e");
    }

    _isResapanLoading = false;
    notifyListeners();
  }

  // =====================================================
  // FETCH WILAYAH DISTRIBUTION (BARU)
  // =====================================================

  Future<void> fetchWilayahDistribution() async {
    if (_isWilayahLoading) return;

    _isWilayahLoading = true;
    _wilayahError = '';

    notifyListeners();

    try {
      final result = await _service.getWilayahDistribution(
        resor: _selectedResor,
        sektor: _selectedSektor,
        idJenisLahan: _selectedJenisLahan,
        jenisKomoditi: _selectedJenisKomoditi,
        idKomoditi: _selectedKomoditiId,
      );

      _wilayahDistribution = result;
    } catch (e, stack) {
      _wilayahError = 'Gagal mendapatkan data wilayah';
      _wilayahDistribution = [];

      debugPrint("Wilayah Distribution Provider Error: $e");
      debugPrintStack(stackTrace: stack);
    } finally {
      _isWilayahLoading = false;
      notifyListeners();
    }
  }

  // =====================================================
  // CLEAR DATA
  // =====================================================

  void clearData() {
    _dashboardData = null;
    _mapPotensi = null;
    _resapanData = null;
    _wilayahDistribution = [];

    notifyListeners();
  }
}
