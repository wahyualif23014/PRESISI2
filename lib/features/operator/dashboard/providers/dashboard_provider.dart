// lib/features/operator/dashboard/providers/operator_dashboard_provider.dart

import 'package:KETAHANANPANGAN/features/operator/dashboard/data/services/dashboard_service.dart';
import 'package:flutter/material.dart';
import '../data/model/operator_dashboard_model.dart';

class OperatorDashboardProvider extends ChangeNotifier {
  final _service = OperatorDashboardService();
  
  OperatorDashboardModel _data = OperatorDashboardModel.empty();
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
      _data = await _service.getOperatorData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}