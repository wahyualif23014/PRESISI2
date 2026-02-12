import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/data/models/region_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/data/repos/region_service.dart';

class RegionProvider with ChangeNotifier {
  final RegionService _service = RegionService();

  List<WilayahModel> _allData = []; // Data master (tidak berubah)
  List<WilayahModel> _displayData = []; // Data yang tampil di UI

  bool _isLoading = false;
  String? _errorMessage;
  bool _isBannerVisible = true;

  // State Filter
  String _searchQuery = "";
  List<String> _selectedKabupatenFilters =
      []; // Menyimpan filter kabupaten yang aktif

  // State Accordion
  final Set<String> _expandedKabupaten = {};
  final Set<String> _expandedKecamatan = {};

  // Getters
  List<WilayahModel> get displayData => _displayData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBannerVisible => _isBannerVisible;

  // Ambil list unik Kabupaten untuk menu Filter
  List<String> get uniqueKabupatenList {
    return _allData.map((e) => e.kabupaten).toSet().toList()..sort();
  }

  bool isKabupatenExpanded(String kab) => _expandedKabupaten.contains(kab);
  bool isKecamatanExpanded(String kec) => _expandedKecamatan.contains(kec);

  // --- ACTIONS ---

  Future<void> fetchRegions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.fetchRegions();
      _allData = data;
      _applyFilters(); // Terapkan filter awal (tampilkan semua & urutkan)
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 1. Fungsi Search Real-time
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  Future<bool> updateData(String kode, double lat, double lng) async {
    final success = await _service.updateCoordinate(kode, lat, lng);
    if (success) {
      // Jika sukses di backend, refresh data di list agar tampilan berubah
      await fetchRegions();
      return true;
    }
    return false;
  }

  // 2. Fungsi Filter by Kabupaten
  void applyFilterKabupaten(List<String> selectedKabupatens) {
    _selectedKabupatenFilters = selectedKabupatens;
    _applyFilters();
    notifyListeners();
  }

  // 3. Logika Inti: Gabungan Search & Filter + Sorting
  void _applyFilters() {
    // A. Filter Data
    var temp =
        _allData.where((item) {
          // Cek Search Query
          final matchSearch =
              _searchQuery.isEmpty ||
              item.namaDesa.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item.kecamatan.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item.kabupaten.toLowerCase().contains(_searchQuery.toLowerCase());

          // Cek Filter Kabupaten
          final matchFilter =
              _selectedKabupatenFilters.isEmpty ||
              _selectedKabupatenFilters.contains(item.kabupaten);

          return matchSearch && matchFilter;
        }).toList();

    // B. Sorting Wajib (Agar grouping UI rapi)
    temp.sort((a, b) {
      int kabCmp = a.kabupaten.compareTo(b.kabupaten);
      if (kabCmp != 0) return kabCmp;
      int kecCmp = a.kecamatan.compareTo(b.kecamatan);
      if (kecCmp != 0) return kecCmp;
      return a.namaDesa.compareTo(b.namaDesa);
    });

    _displayData = temp;

    // C. Auto Expand jika sedang mencari/filter
    if (_searchQuery.isNotEmpty || _selectedKabupatenFilters.isNotEmpty) {
      _expandAllFiltered();
    } else {
      _collapseAll(); // Opsional: tutup semua jika reset
      _expandAllFiltered(); // Atau buka semua default
    }
  }

  // --- UI Helpers ---
  void toggleKabupaten(String namaKab) {
    if (_expandedKabupaten.contains(namaKab)) {
      _expandedKabupaten.remove(namaKab);
    } else {
      _expandedKabupaten.add(namaKab);
    }
    notifyListeners();
  }

  void toggleKecamatan(String namaKec) {
    if (_expandedKecamatan.contains(namaKec)) {
      _expandedKecamatan.remove(namaKec);
    } else {
      _expandedKecamatan.add(namaKec);
    }
    notifyListeners();
  }

  void closeBanner() {
    _isBannerVisible = false;
    notifyListeners();
  }

  void refresh() {
    fetchRegions();
  }

  void _expandAllFiltered() {
    _expandedKabupaten.clear();
    _expandedKecamatan.clear();
    for (var item in _displayData) {
      _expandedKabupaten.add(item.kabupaten);
      _expandedKecamatan.add(item.kecamatan);
    }
  }

  void _collapseAll() {
    _expandedKabupaten.clear();
    _expandedKecamatan.clear();
  }
}
