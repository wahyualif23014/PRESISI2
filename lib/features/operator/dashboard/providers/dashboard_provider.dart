import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/operator/dashboard/data/services/dashboard_service.dart';
import 'package:KETAHANANPANGAN/features/operator/dashboard/data/model/operator_dashboard_model.dart';

class OperatorDashboardProvider with ChangeNotifier {
  // Pastikan nama class di file service adalah DashboardService
  final _service = DashboardService();

  OperatorDashboardModel _data = OperatorDashboardModel(
    totalLahan: 0,
    tugasPending: 0,
    daftarLahan: [],
  );

  bool _isLoading = false;
  String? _errorMessage;

  OperatorDashboardModel get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOperatorData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _service.getOperatorDashboardData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
