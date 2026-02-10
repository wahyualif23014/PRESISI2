import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:flutter/material.dart';
import '../data/services/personel_services.dart';

class PersonelProvider with ChangeNotifier {
  final PersonelService _service = PersonelService();

  // State Variables
  List<UserModel> _personelList = []; // List Utama (Hasil Filter)
  List<UserModel> _fullList = [];     // List Cadangan (Master Data)
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<UserModel> get personelList => _personelList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- FETCH DATA ---
  Future<void> fetchPersonel() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getAllPersonel();
      _fullList = data;     // Simpan ke master
      _personelList = data; // Tampilkan semua di awal
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- SEARCH (Client Side) ---
  void search(String keyword) {
    if (keyword.isEmpty) {
      _personelList = _fullList; // Reset ke list penuh
    } else {
      final query = keyword.toLowerCase();
      _personelList = _fullList.where((user) {
        return user.namaLengkap.toLowerCase().contains(query) ||
               user.idTugas.toLowerCase().contains(query) || // Cari by ID Tugas
               user.username.toLowerCase().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  // --- CRUD ACTIONS ---

  Future<void> addPersonel(UserModel user, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.addPersonel(user, password);
      await fetchPersonel(); // Refresh list otomatis
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // Lempar error ke UI utk SnackBar
    }
  }

  Future<void> updatePersonel(UserModel user) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updatePersonel(user);
      await fetchPersonel();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePersonel(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.deletePersonel(id);
      await fetchPersonel();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}