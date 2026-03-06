import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';
import '../../data/repo/recap_repo.dart';

enum RecapState { initial, loading, loaded, error, empty }

class RecapController extends ChangeNotifier {
  final RecapRepo _repo = RecapRepo();

  RecapState _state = RecapState.initial;
  RecapState get state => _state;

  String? _errorMessage; // Tambahkan ini
  String? get errorMessage => _errorMessage; // Tambahkan ini

  List<RecapModel> _allData = [];
  Map<String, List<RecapModel>> _groupedData = {};
  Map<String, List<RecapModel>> get groupedData => _groupedData;

  String _searchQuery = ""; // Tambahkan ini
  Map<String, String> _activeFilters = {};

  Future<void> fetchData({Map<String, String>? filters}) async {
    _state = RecapState.loading;
    _errorMessage = null; // Tambahkan ini
    if (filters != null) _activeFilters = filters;
    notifyListeners();

    try {
      _allData = await _repo.getRecapData(filters: _activeFilters);
      _processData();
      _state = _allData.isEmpty ? RecapState.empty : RecapState.loaded;
    } catch (e) {
      _errorMessage = e.toString(); // Tambahkan ini
      _state = RecapState.error;
    }
    notifyListeners();
  }

  // Tambahkan fungsi onFilterComplex
  void onFilterComplex(Map<String, String> newFilters) {
    if (newFilters.isEmpty) {
      _searchQuery = "";
    }
    _activeFilters = newFilters;
    fetchData(filters: _activeFilters);
  }

  // Tambahkan fungsi onSearch
  void onSearch(String query) {
    _searchQuery = query.toLowerCase();
    _processData();
    notifyListeners();
  }

  void toggleSelection(String id, bool val) {
    for (var item in _allData) {
      if (item.id.startsWith(id)) {
        item.isSelected = val;
      }
    }
    _processData();
    notifyListeners();
  }

  void _processData() {
    Map<String, List<RecapModel>> result = {};
    String currentPolres = "";
    String currentPolsek = "";

    for (var item in _allData) {
      if (item.type == RecapRowType.polres) {
        currentPolres = item.namaWilayah;
        currentPolsek = "";
        if (!result.containsKey(currentPolres)) result[currentPolres] = [];
      } else if (item.type == RecapRowType.polsek) {
        currentPolsek = item.namaWilayah;
      }

      // Filter pencarian lokal
      bool matchesSearch =
          _searchQuery.isEmpty ||
          currentPolres.toLowerCase().contains(_searchQuery);

      if (matchesSearch && currentPolres.isNotEmpty) {
        if (item.type != RecapRowType.polres) {
          result[currentPolres]?.add(
            item.type == RecapRowType.desa
                ? item.copyWith(
                  namaPolsek: currentPolsek,
                  isSelected: item.isSelected,
                )
                : item,
          );
        }
      }
    }
    _groupedData = result;
  }

  Future<String?> downloadExcel() async {
    final selectedIds = _allData
        .where((e) => e.isSelected && e.type == RecapRowType.desa)
        .map((e) => e.id)
        .join(',');

    Map<String, String> exportParams = Map.from(_activeFilters);
    if (selectedIds.isNotEmpty) {
      exportParams['selected_ids'] = selectedIds;
    }

    return await _repo.downloadExcel(filters: exportParams);
  }
}
