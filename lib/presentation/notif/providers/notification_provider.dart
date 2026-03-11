import 'dart:async'; // 👇 TAMBAHAN WAJIB: Untuk menjalankan Timer
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repos/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  // State untuk Daftar Notifikasi
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  // State untuk Loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // State untuk Error Message
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // State untuk Badge Lonceng (Jumlah Belum Dibaca)
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // 👇 TAMBAHAN VARIABEL: Untuk menyimpan status mesin waktu (Timer)
  Timer? _pollingTimer;

  // 1. Fungsi untuk Mengambil Daftar Notifikasi
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Memberitahu UI untuk menampilkan animasi loading

    try {
      final data = await _repository.fetchNotifications();
      _notifications = data;
      
      if (_notifications.isEmpty) {
        _errorMessage = 'Tidak ada notifikasi';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners(); // Memberitahu UI bahwa loading selesai & data siap
    }
  }

  // 2. Fungsi untuk Mengambil Jumlah Notifikasi Belum Dibaca (Untuk Badge Lonceng)
  Future<void> fetchUnreadCount() async {
    try {
      final count = await _repository.fetchUnreadCount();
      _unreadCount = count;
      notifyListeners();
    } catch (e) {
      _unreadCount = 0;
      notifyListeners();
    }
  }

  // (Opsional) Fungsi untuk me-refresh data (misal saat pull-to-refresh)
  Future<void> refreshNotifications() async {
    await fetchNotifications();
    await fetchUnreadCount();
  }

  // ========================================================
  // 👇 TAMBAHAN KODE: FUNGSI YANG DICARI OLEH main_layout.dart 👇
  // ========================================================

  // Fungsi untuk menyalakan mesin pengecekan otomatis (setiap 15 detik)
  void startPolling() {
    // Ambil data lonceng sekali saat fungsi pertama kali dipanggil
    fetchUnreadCount();
    
    // Hentikan timer lama jika sebelumnya sudah berjalan (mencegah double loading)
    _pollingTimer?.cancel();
    
    // Buat Timer yang memanggil API getUnreadCount otomatis setiap 15 Detik
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      fetchUnreadCount();
    });
  }

  // Fungsi untuk mematikan mesin polling
  void stopPolling() {
    _pollingTimer?.cancel();
  }

  // Fungsi bawaan Flutter: Wajib dipanggil untuk membersihkan memori saat aplikasi ditutup
  @override
  void dispose() {
    stopPolling(); // Matikan timer sebelum provider dihancurkan
    super.dispose();
  }
}