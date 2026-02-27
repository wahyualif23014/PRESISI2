import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';
import '../../data/repo/recap_repo.dart';

enum RecapState { initial, loading, loaded, error, empty }

class RecapController extends ChangeNotifier {
  final RecapRepo _repo = RecapRepo();

  // --- STATE ---
  RecapState _state = RecapState.initial;
  RecapState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<RecapModel> _allData = []; // Data mentah dari API
  Map<String, List<RecapModel>> _groupedData = {}; // Data untuk UI
  Map<String, List<RecapModel>> get groupedData => _groupedData;

  // --- FILTER STATE ---
  String _searchQuery = "";
  // Map ini menyimpan parameter untuk dikirim ke API
  Map<String, String> _activeFilters = {};

  // --- METHODS ---

  Future<void> fetchData({Map<String, String>? filters}) async {
    _state = RecapState.loading;
    _errorMessage = null;

    // Simpan filter jika ada (digunakan untuk download excel nanti)
    if (filters != null) {
      _activeFilters = filters;
    }

    notifyListeners();

    try {
      // Mengirim filter ke repository untuk query di sisi database
      _allData = await _repo.getRecapData(filters: _activeFilters);
      _processData();

      _state = _allData.isEmpty ? RecapState.empty : RecapState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = RecapState.error;
    }
    notifyListeners();
  }

  // Fungsi khusus untuk menangani filter dari Dialog
  void onFilterComplex(Map<String, String> newFilters) {
    // REFAKTOR: Jika newFilters kosong (hasil Reset), bersihkan query pencarian teks juga
    if (newFilters.isEmpty) {
      _searchQuery = "";
    }

    _activeFilters = newFilters;
    fetchData(filters: _activeFilters);
  }

  void onSearch(String query) {
    _searchQuery = query.toLowerCase();
    _processData();
    notifyListeners();
  }

  // --- LOGIKA PEMROSESAN DATA ---
  void _processData() {
    Map<String, List<RecapModel>> result = {};
    String currentPolres = "";
    String currentPolsek = "";

    for (var item in _allData) {
      // 1. LEVEL POLRES
      if (item.type == RecapRowType.polres) {
        currentPolres = item.namaWilayah;
        currentPolsek = ""; // Reset polsek saat ganti polres

        if (!result.containsKey(currentPolres)) {
          result[currentPolres] = [];
        }
      }
      // 2. LEVEL POLSEK
      else if (item.type == RecapRowType.polsek) {
        currentPolsek = item.namaWilayah;
      }

      // PERBAIKAN: Logic Pencarian Lokal hanya berdasarkan nama Kabupaten (Polres)
      bool matchesSearch =
          _searchQuery.isEmpty ||
          currentPolres.toLowerCase().contains(_searchQuery);

      if (matchesSearch && currentPolres.isNotEmpty) {
        if (item.type != RecapRowType.polres) {
          // Tambahkan item (Polsek/Desa) ke dalam grup Polresnya
          result[currentPolres]?.add(
            item.type == RecapRowType.desa
                ? item.copyWith(namaPolsek: currentPolsek)
                : item,
          );
        }
      }
    }

    // Bersihkan grup yang tidak memiliki anggota hasil search
    result.removeWhere((key, value) => value.isEmpty);
    _groupedData = result;
  }

  Future<String?> downloadExcel() async {
    return await _repo.downloadExcel(filters: _activeFilters);
  }
}
