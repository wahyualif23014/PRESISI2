import 'package:flutter/material.dart';
import '../models/position_model.dart' show JabatanModel;
import '../services/jabatan_service.dart';

class JabatanProvider with ChangeNotifier {
  final JabatanService _service = JabatanService();
  List<JabatanModel> _allData = [];
  List<JabatanModel> _displayData = [];
  bool _isLoading = false;

  List<JabatanModel> get displayData => _displayData;
  bool get isLoading => _isLoading;
  int get selectedCount => _displayData.where((e) => e.isSelected).length;
  bool get isAllSelected => _displayData.isNotEmpty && selectedCount == _displayData.length;

  Future<void> fetchJabatan() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allData = await _service.getJabatanList();
      _displayData = List.from(_allData);
    } catch (e) {
      debugPrint("Error fetching jabatan: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FUNGSI BARU: Hapus satu data spesifik (Sesuai ID int di Go) ---
  Future<void> deleteOne(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _service.deleteJabatan(id);
      if (success) {
        // Optimistic update: hapus dari list lokal agar UI cepat merespon
        _allData.removeWhere((e) => e.id == id);
        _displayData.removeWhere((e) => e.id == id);
      }
    } finally {
      await fetchJabatan(); // Sinkronisasi ulang dengan DB
    }
  }

  // Soft delete massal untuk item yang dipilih melalui checkbox
  Future<void> deleteSelected() async {
    final selectedItems = _displayData.where((x) => x.isSelected).toList();
    if (selectedItems.isEmpty) return;

    _isLoading = true;
    notifyListeners();
    try {
      for (var e in selectedItems) {
        await _service.deleteJabatan(e.id);
      }
    } finally {
      await fetchJabatan();
    }
  }

  // Menambah jabatan baru
  Future<void> addNewData(String n) async {
    final success = await _service.createJabatan(n);
    if (success) await fetchJabatan();
  }

  // Update data menggunakan ID int
  Future<void> updateData(int id, String n) async {
    final success = await _service.updateJabatan(id, n);
    if (success) await fetchJabatan();
  }

  void search(String q) {
    _displayData = _allData
        .where((e) => e.namaJabatan.toLowerCase().contains(q.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void toggleSingleSelection(int id) {
    final i = _displayData.indexWhere((e) => e.id == id);
    if (i != -1) {
      _displayData[i].isSelected = !_displayData[i].isSelected;
      notifyListeners();
    }
  }

  void toggleSelectAll(bool? v) {
    for (var e in _displayData) {
      e.isSelected = v ?? false;
    }
    notifyListeners();
  }
}