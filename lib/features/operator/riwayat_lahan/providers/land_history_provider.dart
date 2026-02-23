import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/models/lahan_history_model.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/repos/lahan_history_repos.dart';

class LandHistoryProvider extends ChangeNotifier {
  final LandHistoryRepository _repo = LandHistoryRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LandHistorySummaryModel? _summaryData;
  LandHistorySummaryModel? get summaryData => _summaryData;

  List<LandHistoryItemModel> _allList = [];
  Map<String, List<LandHistoryItemModel>> _groupedData = {};
  Map<String, List<LandHistoryItemModel>> get groupedData => _groupedData;

  bool get isEmpty => _groupedData.isEmpty;

  Future<void> fetchHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        // _repo.getSummaryStats(),
        _repo.getHistoryList(),
      ]);

      _summaryData = results[0] as LandHistorySummaryModel;
      _allList = results[1] as List<LandHistoryItemModel>;
      _groupedData = _groupDataByRegion(_allList);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      _groupedData = _groupDataByRegion(_allList);
    } else {
      final filtered =
          _allList.where((item) {
            final searchLower = query.toLowerCase();
            return item.regionGroup.toLowerCase().contains(searchLower) ||
                item.subRegionGroup.toLowerCase().contains(searchLower) ||
                item.policeName.toLowerCase().contains(searchLower) ||
                item.picName.toLowerCase().contains(searchLower);
          }).toList();
      _groupedData = _groupDataByRegion(filtered);
    }
    notifyListeners();
  }

  void applyFilter(String keyword, List<String> selectedFilters) {
    List<LandHistoryItemModel> filteredList = _allList;

    if (keyword.isNotEmpty) {
      filteredList =
          filteredList.where((item) {
            final key = keyword.toLowerCase();
            return item.policeName.toLowerCase().contains(key) ||
                item.picName.toLowerCase().contains(key) ||
                item.regionGroup.toLowerCase().contains(key);
          }).toList();
    }

    if (selectedFilters.isNotEmpty) {
      filteredList =
          filteredList.where((item) {
            // Mencocokkan dengan status atau landCategory sesuai kebutuhan filter
            return selectedFilters.contains(item.status) ||
                selectedFilters.contains(item.landCategory);
          }).toList();
    }

    _groupedData = _groupDataByRegion(filteredList);
    notifyListeners();
  }

  void resetFilter() {
    _groupedData = _groupDataByRegion(_allList);
    notifyListeners();
  }

  Map<String, List<LandHistoryItemModel>> _groupDataByRegion(
    List<LandHistoryItemModel> data,
  ) {
    final Map<String, List<LandHistoryItemModel>> grouped = {};
    for (var item in data) {
      // Mengelompokkan berdasarkan regionGroup (Level 1)
      grouped.putIfAbsent(item.regionGroup, () => []).add(item);
    }
    return grouped;
  }
}
