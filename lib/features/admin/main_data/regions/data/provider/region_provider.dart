import 'package:flutter/material.dart';
// Import Model & Repo
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/data/models/region_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/data/repos/region_repository.dart';

class RegionProvider with ChangeNotifier {
  List<WilayahModel> _allData = []; // Data mentah dari repo
  List<WilayahModel> _displayData = []; // Data hasil filter/search untuk UI
  
  // State UI
  bool _isLoading = false;
  String? _errorMessage;
  bool _isBannerVisible = true;

  // State Accordion (Grouping)
  final Set<String> _expandedKabupaten = {};
  final Set<String> _expandedKecamatan = {};

  // --- GETTERS ---
  List<WilayahModel> get displayData => _displayData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBannerVisible => _isBannerVisible;
  
  // Getter untuk cek status expand di UI
  bool isKabupatenExpanded(String kab) => _expandedKabupaten.contains(kab);
  bool isKecamatanExpanded(String kec) => _expandedKecamatan.contains(kec);

  // --- ACTIONS ---

  // 1. Fetch Data Awal
  Future<void> fetchRegions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Panggil Repo (Simulasi Async jika perlu)
      final data = WilayahRepository.getDummyData();
      
      // Sorting wajib agar grouping di UI berurutan
      data.sort((a, b) {
        int kabCmp = a.kabupaten.compareTo(b.kabupaten);
        if (kabCmp != 0) return kabCmp;
        return a.kecamatan.compareTo(b.kecamatan);
      });

      _allData = data;
      _displayData = List.from(data);

      // Default: Expand All saat load pertama
      _expandAll(); 

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Search Logic
  void search(String query) {
    if (query.isEmpty) {
      _displayData = List.from(_allData);
    } else {
      final lowerQuery = query.toLowerCase();
      _displayData = _allData.where((item) {
        return item.namaDesa.toLowerCase().contains(lowerQuery) ||
               item.kecamatan.toLowerCase().contains(lowerQuery) ||
               item.kabupaten.toLowerCase().contains(lowerQuery);
      }).toList();

      // Saat search, otomatis buka semua accordion agar hasil terlihat
      _expandAllFiltered();
    }
    notifyListeners();
  }

  // 3. Toggle Accordion
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

  // 4. UI Helpers
  void closeBanner() {
    _isBannerVisible = false;
    notifyListeners();
  }

  void refresh() {
    fetchRegions();
  }

  // --- INTERNAL HELPERS ---
  void _expandAll() {
    _expandedKabupaten.clear();
    _expandedKecamatan.clear();
    for (var item in _allData) {
      _expandedKabupaten.add(item.kabupaten);
      _expandedKecamatan.add(item.kecamatan);
    }
  }

  void _expandAllFiltered() {
    for (var item in _displayData) {
      _expandedKabupaten.add(item.kabupaten);
      _expandedKecamatan.add(item.kecamatan);
    }
  }
}