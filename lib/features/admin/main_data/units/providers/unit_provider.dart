import 'package:flutter/material.dart';
import '../data/models/unit_region_viewmodel.dart';


class UnitProvider with ChangeNotifier {
  // --- STATE ---
  List<UnitRegionViewModel> _originalList = []; // Data asli dari API
  List<UnitRegionViewModel> _filteredList = []; // Data yang ditampilkan (hasil search)
  
  bool _isLoading = false;
  String? _errorMessage;

  // --- GETTERS ---
  List<UnitRegionViewModel> get units => _filteredList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getter untuk menghitung total unit (Logic dipindah ke sini agar UI bersih)
  int get totalUnits {
    int total = 0;
    for (var region in _filteredList) {
      total += 1; // Hitung Polres
      total += region.polseks.length; // Hitung anak-anak Polseknya
    }
    return total;
  }

  // --- ACTIONS ---

  Future<void> fetchUnits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // PANGGIL SERVICE ANDA DI SINI
      // final result = await UnitService().getUnits(); 
      
      // --- DUMMY DATA (Hapus ini jika Service sudah siap) ---
      await Future.delayed(const Duration(seconds: 1)); // Simulasi delay
      
      _filteredList = List.from(_originalList); // Copy data ke filtered
      _isLoading = false;
      notifyListeners();

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi Search Lokal
  void search(String query) {
    if (query.isEmpty) {
      _filteredList = List.from(_originalList);
    } else {
      _filteredList = _originalList.where((region) {
        final searchLower = query.toLowerCase();
        final matchPolres = region.polres.namaPolres.toLowerCase().contains(searchLower);
        final matchPolsek = region.polseks.any((p) => p.namaPolsek.toLowerCase().contains(searchLower));
        
        return matchPolres || matchPolsek;
      }).toList();
    }
    notifyListeners();
  }

  // Fungsi Toggle Expand/Collapse Accordion
  void toggleExpand(int index) {
    _filteredList[index].isExpanded = !_filteredList[index].isExpanded;
    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchUnits();
  }
}