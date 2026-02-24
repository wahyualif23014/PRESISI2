import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  final String baseUrl = 'http://10.16.8.244:8080'; 

  // Helper Private untuk mengambil Header + Token secara konsisten
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    if (token == null) throw Exception('Sesi berakhir. Silakan login ulang.');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. GET: Ambil Semua Data User (Admin Only)
  Future<List<dynamic>> getUsers() async {
    final headers = await _getHeaders();
    // Gunakan /api/admin sesuai rute di main.go
    final response = await http.get(
      Uri.parse('$baseUrl/api/admin/users'), 
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    } else {
      throw Exception('Gagal memuat data user: ${response.statusCode}');
    }
  }

  // 2. POST: Daftarkan Personel Baru (IAM)
  Future<void> createUser(Map<String, dynamic> userData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/users'),
      headers: headers,
      body: jsonEncode(userData),
    );

    if (response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Gagal mendaftarkan personel');
    }
  }

  // 3. PUT: Update Data Personel
  Future<void> updateUser(int id, Map<String, dynamic> userData) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/admin/users/$id'),
      headers: headers,
      body: jsonEncode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui data personel');
    }
  }

  // 4. DELETE: Hapus Personel (Soft Delete di Backend)
  Future<void> deleteUser(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/admin/users/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus personel');
    }
  }
}