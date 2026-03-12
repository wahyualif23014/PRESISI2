import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/models/lahan_history_model.dart'
    show LandHistoryItemModel, LandHistorySummaryModel;
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/repos/lahan_history_repos.dart'
    show LandHistoryRepository;
import 'package:flutter/foundation.dart';

class LandHistoryProvider extends ChangeNotifier {
  final LandHistoryRepository _repository = LandHistoryRepository();

  // ==============================
  // STATE
  // ==============================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LandHistorySummaryModel _summary = LandHistorySummaryModel(
    totalPotensiLahan: 0,
    totalTanamLahan: 0,
    totalPanenLahanHa: 0,
    totalPanenLahanTon: 0,
    totalSerapanTon: 0,
  );

  LandHistorySummaryModel get summary => _summary;

  List<LandHistoryItemModel> _historyList = [];
  List<LandHistoryItemModel> get historyList => _historyList;

  Map<String, List<String>> _filterOptions = {
    "polres": [],
    "polsek": [],
    "jenis_lahan": [],
    "komoditi": [],
  };

  Map<String, List<String>> get filterOptions => _filterOptions;

  Map<String, String> _activeFilters = {};
  Map<String, String> get activeFilters => _activeFilters;

  String _searchKeyword = "";

  // ==============================
  // SET SEARCH
  // ==============================

  void setSearch(String keyword) {
    _searchKeyword = keyword;
    fetchHistory();
  }

  // ==============================
  // SET FILTER
  // ==============================

  void setFilter(String key, String value) {
    if (value.isEmpty) {
      _activeFilters.remove(key);
    } else {
      _activeFilters[key] = value;
    }
    fetchHistory();
  }

  void clearFilters() {
    _activeFilters.clear();
    fetchHistory();
  }

  // ==============================
  // FETCH SUMMARY
  // ==============================

  Future<void> fetchSummary() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _repository.getSummaryStats();
      _summary = result;
    } catch (e) {
      debugPrint("Provider Summary Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==============================
  // FETCH FILTER OPTIONS
  // ==============================

  Future<void> fetchFilterOptions({String? polres}) async {
    try {
      final result = await _repository.getFilterOptions(polres: polres);
      _filterOptions = result;

      notifyListeners();
    } catch (e) {
      debugPrint("Provider Filter Error: $e");
    }
  }

  // ==============================
  // FETCH HISTORY LIST
  // ==============================

  Future<void> fetchHistory() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _repository.getHistoryList(
        keyword: _searchKeyword,
        filters: _activeFilters,
      );

      _historyList = result;
    } catch (e) {
      debugPrint("Provider History Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ==============================
  // INITIAL LOAD
  // ==============================

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([fetchSummary(), fetchFilterOptions(), fetchHistory()]);

    _isLoading = false;
    notifyListeners();
  }
}
