import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; //
import '../models/notification_model.dart';

class NotificationRepository {
  // Samakan IP dengan AuthService Anda
  final String baseUrl = 'http://192.168.43.201:8080/api';
  
  // Gunakan FlutterSecureStorage untuk konsistensi
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Fungsi untuk mengambil token menggunakan key 'jwt_token'
  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token'); 
  }

  // Fungsi Mengambil Daftar Notifikasi
  Future<List<NotificationModel>> fetchNotifications() async {
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', //
        },
      ).timeout(const Duration(seconds: 15)); // Tambahkan timeout seperti di AdminService

      // --- DEBUGGING ---
      print('=== CEK API NOTIFIKASI ===');
      print('Token yang dikirim: $token');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        print('Token tidak valid atau sudah kadaluarsa.');
        return [];
      } else {
        print('Gagal mengambil data. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error saat fetch notifikasi: $e');
      return [];
    }
  }

  // Fungsi Menghitung Badge Lonceng Merah
  Future<int> fetchUnreadCount() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetch unread count: $e');
      return 0;
    }
  }
}