import 'package:flutter/material.dart';

import '../data/model/dashboard_ui_model.dart';
import '../data/services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _service = DashboardService();

  // --- STATE ---
  DashboardUiModel? _data;
  bool _isLoading = false;
  String? _errorMessage;

  // --- GETTERS ---
  DashboardUiModel? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- ACTIONS ---

  Future<void> fetchDashboardData() async {
    // 1. Set Loading State
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getDashboardData();

      _data = result;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error Dashboard Provider: $e");
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi Refresh untuk Pull-to-Refresh
  Future<void> refresh() async {
    await fetchDashboardData();
  }
}
