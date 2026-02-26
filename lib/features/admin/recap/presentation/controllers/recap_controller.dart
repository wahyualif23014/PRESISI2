import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';
import '../../data/services/recap_service.dart';

enum RecapState { initial, loading, loaded, error, empty }

class RecapController extends ChangeNotifier {
  final RecapRepo _repo = RecapRepo();
  RecapState _state = RecapState.initial;
  RecapState get state => _state;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  List<RecapModel> _allData = []; 
  Map<String, List<RecapModel>> _groupedData = {}; 
  Map<String, List<RecapModel>> get groupedData => _groupedData;
  String _searchQuery = "";
  Map<String, bool> _activeFilters = {'polres': true, 'polsek': true, 'desa': true};

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

  void _processData() {
    Map<String, List<RecapModel>> result = {};
    String currentPolres = "";
    String currentPolsek = "";
    bool polresMatch = false;
    bool polsekMatch = false;
    final bool showPolres = _activeFilters['polres'] ?? true;
    final bool showPolsek = _activeFilters['polsek'] ?? true;
    final bool showDesa = _activeFilters['desa'] ?? true;

    if (!showPolres && !showPolsek && !showDesa) {
      _groupedData = {};
      return;
    }

    for (var item in _allData) {
      if (item.type == RecapRowType.polres) {
        currentPolres = item.namaWilayah;
        currentPolsek = "";
        polsekMatch = false;
        polresMatch = _searchQuery.isEmpty || currentPolres.toLowerCase().contains(_searchQuery);
        if (!result.containsKey(currentPolres)) result[currentPolres] = [];
      } else if (item.type == RecapRowType.polsek) {
        currentPolsek = item.namaWilayah;
        bool selfMatch = item.namaWilayah.toLowerCase().contains(_searchQuery);
        polsekMatch = _searchQuery.isEmpty || selfMatch || polresMatch;
        if (showPolsek && polsekMatch && currentPolres.isNotEmpty) {
          result[currentPolres]?.add(item);
        }
      } else if (item.type == RecapRowType.desa) {
        bool selfMatch = item.namaWilayah.toLowerCase().contains(_searchQuery);
        bool isVisible = _searchQuery.isEmpty || selfMatch || polsekMatch || polresMatch;
        if (showDesa && isVisible && currentPolres.isNotEmpty) {
          result[currentPolres]?.add(item.copyWith(namaPolsek: currentPolsek));
        }
      }
    }
    result.removeWhere((key, value) => value.isEmpty);
    _groupedData = result;
  }

  Future<String?> downloadExcel() async {
    return await _repo.downloadExcel();
  }
}