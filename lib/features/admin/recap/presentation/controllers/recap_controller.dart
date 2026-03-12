import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';
import '../../data/repo/recap_repo.dart';

enum RecapState { initial, loading, loaded, error, empty }

class RecapController extends ChangeNotifier {
  final RecapRepo _repo = RecapRepo();

  RecapState _state = RecapState.initial;
  RecapState get state => _state;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<RecapModel> _allData = [];
  List<RecapModel> get allItems => _allData;

  Map<String, List<RecapModel>> _groupedData = {};
  Map<String, List<RecapModel>> get groupedData => _groupedData;

  String _searchQuery = "";
  Map<String, String> _activeFilters = {};

  Future<void> fetchData({Map<String, String>? filters}) async {
    _state = RecapState.loading;
    _errorMessage = null;
    if (filters != null) _activeFilters = filters;
    notifyListeners();

    try {
      _allData = await _repo.getRecapData(filters: _activeFilters);
      _processData();
      _state = _allData.isEmpty ? RecapState.empty : RecapState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = RecapState.error;
    }
    notifyListeners();
  }

  void onFilterComplex(Map<String, String> newFilters) {
    if (newFilters.isEmpty) _searchQuery = "";
    _activeFilters = newFilters;
    fetchData(filters: _activeFilters);
  }

  void onSearch(String query) {
    _searchQuery = query.toLowerCase();
    _processData();
    notifyListeners();
  }

  void toggleSelection(String id, bool val) {
    if (id == "ALL") {
      for (var item in _allData) {
        item.isSelected = val;
      }
    } else {
      for (var item in _allData) {
        if (item.id.startsWith(id)) {
          item.isSelected = val;
        }
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

      bool matchesSearch =
          _searchQuery.isEmpty ||
          currentPolres.toLowerCase().contains(_searchQuery) ||
          currentPolsek.toLowerCase().contains(_searchQuery) ||
          item.namaWilayah.toLowerCase().contains(_searchQuery);

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

  Future<String?> downloadExcel({String selection = "ALL"}) async {
    if (_isDownloading) return null;

    _isDownloading = true;
    notifyListeners();

    try {
      Map<String, String> exportParams = Map.from(_activeFilters);

      if (selection != "ALL") {
        exportParams['polres_id'] = selection;
      } else {
        final selectedIds = _allData
            .where((e) => e.isSelected && e.type == RecapRowType.desa)
            .map((e) => e.id)
            .join(',');

        if (selectedIds.isNotEmpty) {
          exportParams['selected_ids'] = selectedIds;
        }
      }

      return await _repo.downloadExcel(filters: exportParams);
    } catch (e) {
      return null;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _allData.clear();
    _groupedData.clear();
    super.dispose();
  }
}
