// lib/features/view/dashboard/providers/viewer_dashboard_provider.dart

import 'package:KETAHANANPANGAN/features/view/dashboard/data/models/viewer_dashboard_model.dart';
import 'package:KETAHANANPANGAN/features/view/dashboard/data/services/dashboard_service.dart';
import 'package:flutter/material.dart';


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