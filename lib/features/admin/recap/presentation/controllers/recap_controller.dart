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

  List<RecapModel> _allData = []; // Data Mentah
  Map<String, List<RecapModel>> _groupedData = {}; // Data Hasil Filter
  Map<String, List<RecapModel>> get groupedData => _groupedData;

  // --- FILTER STATE ---
  String _searchQuery = "";
  Map<String, bool> _activeFilters = {
    'polres': true,
    'polsek': true,
    'desa': true,
  };

  // --- METHODS ---

  Future<void> fetchData() async {
    _state = RecapState.loading;
    notifyListeners();
    try {
      _allData = await _repo.getRecapData();
      _processData();
      _state = _allData.isEmpty ? RecapState.empty : RecapState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = RecapState.error;
    }
    notifyListeners();
  }

  void onSearch(String query) {
    _searchQuery = query.toLowerCase();
    _processData();
    notifyListeners();
  }

  void onFilter(Map<String, bool> newFilters) {
    _activeFilters = newFilters;
    _processData();
    notifyListeners();
  }

  // --- LOGIKA UTAMA (PERBAIKAN DI SINI) ---
  void _processData() {
    Map<String, List<RecapModel>> result = {};

    String currentPolres = "";
    String currentPolsek = "";

    // Status pencarian per level
    bool polresMatch = false;
    bool polsekMatch = false;

    // Ambil status filter
    final bool showPolres = _activeFilters['polres'] ?? true;
    final bool showPolsek = _activeFilters['polsek'] ?? true;
    final bool showDesa = _activeFilters['desa'] ?? true;

    // Jika semua filter mati, kosongkan data
    if (!showPolres && !showPolsek && !showDesa) {
      _groupedData = {};
      return;
    }

    for (var item in _allData) {
      // 1. LEVEL POLRES
      if (item.type == RecapRowType.polres) {
        currentPolres = item.namaWilayah;

        // Reset context
        currentPolsek = "";
        polsekMatch = false;

        // Cek apakah Polres ini dicari
        polresMatch =
            _searchQuery.isEmpty ||
            currentPolres.toLowerCase().contains(_searchQuery);

        // Siapkan list
        if (!result.containsKey(currentPolres)) {
          result[currentPolres] = [];
        }
      }
      // 2. LEVEL POLSEK
      else if (item.type == RecapRowType.polsek) {
        currentPolsek = item.namaWilayah;

        // Cek search: Cocok jika query kosong ATAU nama polsek cocok ATAU induknya (Polres) cocok
        bool selfMatch = item.namaWilayah.toLowerCase().contains(_searchQuery);
        polsekMatch = _searchQuery.isEmpty || selfMatch || polresMatch;

        // FILTER: Masukkan ke list JIKA filter nyala DAN cocok pencarian
        if (showPolsek && polsekMatch) {
          if (currentPolres.isNotEmpty) {
            result[currentPolres]?.add(item);
          }
        }
      }
      // 3. LEVEL DESA
      else if (item.type == RecapRowType.desa) {
        bool selfMatch = item.namaWilayah.toLowerCase().contains(_searchQuery);

        // Desa muncul jika: query kosong ATAU nama desa cocok ATAU Polseknya cocok ATAU Polresnya cocok
        bool isVisible =
            _searchQuery.isEmpty || selfMatch || polsekMatch || polresMatch;

        // FILTER: Cek showDesa
        if (showDesa && isVisible) {
          if (currentPolres.isNotEmpty) {
            // Inject nama Polsek agar UI bisa mengelompokkan jika perlu
            result[currentPolres]?.add(
              item.copyWith(namaPolsek: currentPolsek),
            );
          }
        }
      }
    }

    // Bersihkan hasil kosong
    result.removeWhere((key, value) => value.isEmpty);

    _groupedData = result;
  }

  Future<String?> downloadExcel() async {
    return await _repo.downloadExcel();
  }
}
