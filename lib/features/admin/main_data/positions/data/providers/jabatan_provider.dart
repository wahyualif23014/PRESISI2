import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/models/position_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/repos/position_repository.dart';

class JabatanProvider with ChangeNotifier {
  // --- STATE ---
  List<JabatanModel> _allData = [];
  List<JabatanModel> _displayData = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- GETTERS ---
  List<JabatanModel> get displayData => _displayData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getter Seleksi
  int get selectedCount => _displayData.where((e) => e.isSelected).length;
  bool get isAllSelected => _displayData.isNotEmpty && _displayData.length == selectedCount;

  // --- ACTIONS ---

  Future<void> fetchJabatan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allData = await JabatanRepository.getJabatanList();
      _displayData = List.from(_allData);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error loading data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      _displayData = List.from(_allData);
    } else {
      final searchLower = query.toLowerCase();
      _displayData = _allData.where((item) {
        final titleLower = item.namaJabatan.toLowerCase();
        final nameLower = (item.namaPejabat ?? '').toLowerCase();
        return titleLower.contains(searchLower) || nameLower.contains(searchLower);
      }).toList();
    }
    notifyListeners();
  }

  // --- SELECTION LOGIC ---

  void toggleSelectAll(bool? val) {
    if (val != null) {
      for (var item in _displayData) {
        item.isSelected = val;
      }
      notifyListeners();
    }
  }

  void toggleSingleSelection(String id) {
    final index = _displayData.indexWhere((e) => e.id == id);
    if (index != -1) {
      _displayData[index].isSelected = !_displayData[index].isSelected;
      notifyListeners();
    }
  }

  // --- CRUD OPERATIONS (Local Logic) ---

  void addNewData(String jabatan, String nama, String nrp, String tgl) {
    final newItem = JabatanModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID Dummy
      namaJabatan: jabatan.isEmpty ? "Jabatan Baru" : jabatan,
      namaPejabat: nama.isEmpty ? "Personel Baru" : nama,
      nrp: nrp,
      tanggalPeresmian: tgl,
    );
    
    _allData.add(newItem);
    // Reset search agar data baru terlihat (opsional, atau tetap di filter search)
    search(""); 
    notifyListeners();
  }

  void deleteSingle(String id) {
    _displayData.removeWhere((e) => e.id == id);
    _allData.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void deleteSelected() {
    // Ambil ID yang mau dihapus dulu
    final idsToDelete = _displayData.where((e) => e.isSelected).map((e) => e.id).toSet();
    
    _displayData.removeWhere((e) => idsToDelete.contains(e.id));
    _allData.removeWhere((e) => idsToDelete.contains(e.id));
    notifyListeners();
  }

  void refresh() {
    fetchJabatan();
  }
}