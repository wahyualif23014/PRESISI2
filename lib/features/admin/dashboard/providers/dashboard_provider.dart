import 'package:flutter/material.dart';

// --- IMPORT MODEL UI BARU ---
import '../data/model/dashboard_ui_model.dart'; 

// --- IMPORT SERVICE ---
import '../data/services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  // Inisialisasi Service
  final DashboardService _service = DashboardService();

  // --- STATE ---
  // Menggunakan DashboardUiModel karena ini yang dikembalikan oleh Service sekarang
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
      // 2. Panggil Service (Service akan mengambil data dari semua Repo)
      final result = await _service.getDashboardData();
      
      // 3. Update State Sukses
      _data = result;
      _isLoading = false;
      notifyListeners(); 

    } catch (e) {
      // 4. Handle Error
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