import 'package:flutter/material.dart';
// Import Master Model tunggal dari folder Auth agar konsisten di seluruh aplikasi
import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import '../data/services/personel_services.dart';

class PersonelProvider with ChangeNotifier {
  final PersonelService _service = PersonelService();

  // --- STATE VARIABLES ---
  List<UserModel> _personelList = []; // List yang aktif ditampilkan di UI
  List<UserModel> _fullList = [];     // Backup data asli (Cache) untuk keperluan filtering
  bool _isLoading = false;
  String? _errorMessage;

  // --- GETTERS ---
  List<UserModel> get personelList => _personelList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- 1. FETCH DATA (Ambil Semua Data) ---
  Future<void> fetchPersonel() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getAllPersonel();
      _fullList = data;
      _personelList = List.from(data); // Inisialisasi list tampilan
    } catch (e) {
      _errorMessage = "Gagal mengambil data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 2. SEARCH / FILTER LOGIC (Pencarian Mendalam) ---
  void filterPersonel(String keyword) {
    if (keyword.isEmpty) {
      // Jika input kosong, kembalikan ke data asli dari cache
      _personelList = List.from(_fullList);
    } else {
      final query = keyword.toLowerCase();
      _personelList = _fullList.where((user) {
        // Logic: Mencari kecocokan di Nama, NRP, Nama Jabatan, dan Nama Unit/Lokasi
        final matchesName = user.namaLengkap.toLowerCase().contains(query);
        final matchesNrp = user.nrp.toLowerCase().contains(query);
        final matchesJabatan = user.jabatanDetail?.namaJabatan.toLowerCase().contains(query) ?? false;
        final matchesUnit = user.tingkatDetail?.nama.toLowerCase().contains(query) ?? false;

        return matchesName || matchesNrp || matchesJabatan || matchesUnit;
      }).toList();
    }
    notifyListeners();
  }

  // --- 3. ADD PERSONEL (Tambah Data Baru) ---
  Future<void> addPersonel(UserModel user, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.addPersonel(user, password);
      // Refresh data dari server agar mendapatkan ID terbaru dan relasi lengkap
      await fetchPersonel(); 
    } catch (e) {
      _errorMessage = "Gagal menambah personel: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- 4. UPDATE PERSONEL (Optimistic UI Update) ---
  Future<void> updatePersonel(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Hit API Update
      await _service.updatePersonel(updatedUser);

      // Sinkronisasi Cache Lokal: Cari index user yang di-update
      final index = _fullList.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        // Perbarui data di cache memori
        _fullList[index] = updatedUser;

        // Perbarui tampilan (Hanya jika sedang tidak melakukan filter)
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

  // --- 5. DELETE PERSONEL (Hapus Data) ---
  Future<void> deletePersonel(int id) async {
    try {
      await _service.deletePersonel(id);
      
      // Hapus dari cache lokal secara instan agar UI terasa cepat
      _fullList.removeWhere((u) => u.id == id);
      _personelList.removeWhere((u) => u.id == id);
      
      notifyListeners();
    } catch (e) {
      _errorMessage = "Gagal menghapus: $e";
      rethrow;
    }
  }
}