import 'dart:async';
import 'package:http/http.dart' as http; // Biarkan import ini
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Biarkan import ini
import '../model/dasboard_model.dart'; // Pastikan path ini benar

class DashboardService {
  // static const String baseUrl = 'http://10.0.2.2:3000'; 
  // final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<DashboardModel> getDashboardStats() async {
    // --- MODE DUMMY / DEVELOPMENT ---
    // Gunakan ini selagi backend belum siap
    try {
      // 1. Simulasi loading (delay 2 detik) agar terlihat seperti request network
      await Future.delayed(const Duration(seconds: 2));

      // 2. Return data dummy statis dari Model
      return DashboardModel.dummy();
      
    } catch (e) {
      throw Exception('Gagal memuat data dummy: $e');
    }

    // --- MODE PRODUCTION / REAL API (Nanti aktifkan ini) ---
    /*
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null) throw Exception("Token tidak ditemukan, silakan login kembali.");

      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Sesuaikan parsing JSON dengan struktur response backend Anda
        return DashboardModel.fromJson(data['data']); 
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
    */
  }
}