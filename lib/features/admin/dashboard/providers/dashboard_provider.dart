import 'package:flutter/material.dart';
import '../data/model/dasboard_model.dart'; // Pastikan path benar
import '../data/services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _service = DashboardService();

  // --- STATE ---
  DashboardModel? _data;
  bool _isLoading = false;
  String? _errorMessage;

  // --- GETTERS ---
  DashboardModel? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- ACTIONS ---
  
  Future<void> fetchDashboardData() async {
    // Reset state sebelum loading
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); 

    try {
      // Memanggil service (yang sekarang mengembalikan Dummy Data)
      final result = await _service.getDashboardStats();
      
      _data = result;
      _isLoading = false;
      notifyListeners(); 

    } catch (e) {
      debugPrint("Error Dashboard Provider: $e"); // Gunakan debugPrint
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi Refresh
  Future<void> refresh() async {
    // Kosongkan data dulu jika ingin efek 'bersih' saat refresh (opsional)
    // _data = null; 
    await fetchDashboardData();
  }
}