import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/models/position_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/services/jabatan_service.dart';

class JabatanProvider with ChangeNotifier {
  final JabatanService _service = JabatanService();

  List<JabatanModel> _allData = [];
  List<JabatanModel> _displayData = [];
  String _currentQuery = "";

  bool _isLoading = false;
  String? _errorMessage;

  List<JabatanModel> get displayData => _displayData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get selectedCount => _displayData.where((e) => e.isSelected).length;
  bool get isAllSelected =>
      _displayData.isNotEmpty && _displayData.length == selectedCount;

  Future<void> fetchJabatan() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getJabatanList();
      _allData = data;
      _applyFilter();
    } catch (e) {
      _errorMessage = "Gagal mengambil data. Cek koneksi internet.";
      debugPrint("Error Fetch: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _currentQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_currentQuery.isEmpty) {
      _displayData = List.from(_allData);
    } else {
      final searchLower = _currentQuery.toLowerCase();
      _displayData = _allData.where((item) {
        final titleMatch = item.namaJabatan.toLowerCase().contains(searchLower);
        final namaMatch = (item.namaPejabat ?? '').toLowerCase().contains(searchLower);
        return titleMatch || namaMatch;
      }).toList();
    }
  }

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

  void refresh() {
    fetchJabatan();
  }

  Future<void> deleteSingle(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _service.deleteJabatan(id);
      if (success) {
        await fetchJabatan();
      } else {
        _errorMessage = "Gagal menghapus data";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSelected() async {
    _isLoading = true;
    notifyListeners();
    try {
      final selected = _displayData.where((e) => e.isSelected).toList();
      for (var item in selected) {
        await _service.deleteJabatan(item.id);
      }
      await fetchJabatan();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addNewData(String namaJabatan, String? idAnggota) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _service.createJabatan(namaJabatan, idAnggota);
      if (success) {
        await fetchJabatan();
      } else {
        _errorMessage = "Gagal menambah data";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateData(String id, String namaJabatan, String? idAnggota) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _service.updateJabatan(id, namaJabatan, idAnggota);
      if (success) {
        await fetchJabatan();
      } else {
        _errorMessage = "Gagal mengubah data";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
