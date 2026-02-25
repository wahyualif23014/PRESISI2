// lib/features/view/dashboard/providers/dashboard_provider.dart

import 'package:flutter/material.dart';
import '../data/models/viewer_dashboard_model.dart';
import '../data/services/dashboard_service.dart';

class ViewerDashboardProvider extends ChangeNotifier {
  final _service = ViewerDashboardService();

  ViewerDashboardModel _data = ViewerDashboardModel.empty();
  bool _isLoading = false;
  String? _errorMessage;

  ViewerDashboardModel get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchViewerData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _service.getViewerStats();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
