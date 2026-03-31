import 'package:KETAHANANPANGAN/auth/services/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
// Pastikan mengarah ke AdminService yang baru

class PersonelProvider with ChangeNotifier {
  final AdminService _service = AdminService();

  List<UserModel> _personelList = [];
  List<UserModel> _fullList = [];
  List<dynamic> _jabatanOptions = [];
  List<dynamic> _tingkatOptions = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get personelList => _personelList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get jabatanOptions => _jabatanOptions;
  List<dynamic> get tingkatOptions => _tingkatOptions;

  Future<void> fetchPersonel() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Mengambil data mentah (List of dynamic) dari service
      final List<dynamic> rawData = await _service.getUsers();
      _fullList = rawData.map((json) => UserModel.fromJson(json)).toList();
      _personelList = List.from(_fullList);
    } catch (e) {
      _errorMessage = "Gagal mengambil data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FETCH DROPDOWN DATA ---
  Future<void> fetchDropdownData() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Memanggil fungsi baru di service
      _jabatanOptions = await _service.getJabatanList();
      _tingkatOptions = await _service.getTingkatList();
    } catch (e) {
      _errorMessage = "Gagal memuat data dropdown: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. SEARCH / FILTER LOGIC (Tetap karena sudah efisien) ---
  void filterPersonel(String keyword) {
    if (keyword.isEmpty) {
      _personelList = List.from(_fullList);
    } else {
      final query = keyword.toLowerCase();
      _personelList =
          _fullList.where((user) {
            final matchesName = user.namaLengkap.toLowerCase().contains(query);
            final matchesNrp = user.nrp.toLowerCase().contains(query);
            final matchesJabatan =
                user.jabatanDetail?.namaJabatan.toLowerCase().contains(query) ??
                false;
            final matchesUnit =
                user.tingkatDetail?.nama.toLowerCase().contains(query) ?? false;

            return matchesName || matchesNrp || matchesJabatan || matchesUnit;
          }).toList();
    }
    notifyListeners();
  }

  // --- 3. ADD PERSONEL (Sinkron dengan AdminService.createUser) ---
  Future<void> addPersonel(UserModel user, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final Map<String, dynamic> userData = user.toJson();
      userData['password'] = password; // Tambahkan password ke payload JSON

      await _service.createUser(userData);
      await fetchPersonel();
    } catch (e) {
      _errorMessage = "Gagal menambah personel: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePersonel(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Hit API Update menggunakan ID dan JSON
      await _service.updateUser(updatedUser.id, updatedUser.toJson());

      // Update Cache Lokal
      final index = _fullList.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        _fullList[index] = updatedUser;
        _personelList = List.from(_fullList);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal memperbarui data: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 5. DELETE PERSONEL (Sinkron dengan AdminService.deleteUser) ---
  Future<void> deletePersonel(int id) async {
    try {
      await _service.deleteUser(id);

      // Hapus dari cache lokal agar UI instan merespon
      _fullList.removeWhere((u) => u.id == id);
      _personelList.removeWhere((u) => u.id == id);

      notifyListeners();
    } catch (e) {
      _errorMessage = "Gagal menghapus: $e";
      rethrow;
    }
  }
}