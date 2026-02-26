import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Ganti SharedPrefs jadi ini

class AdminService {
  final String baseUrl = 'http://192.168.100.195:8080'; 
  final _storage = const FlutterSecureStorage();

  // Helper Private: Ambil Token dari SecureStorage (Bukan SharedPreferences lagi)
  Future<Map<String, String>> _getHeaders() async {
    // KONSISTENSI: Gunakan key 'jwt_token' sesuai AuthService
    final token = await _storage.read(key: 'jwt_token');
    
    if (token == null) throw Exception('Sesi berakhir. Silakan login ulang.');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. GET: Ambil Semua Data User
  Future<List<dynamic>> getUsers() async {
    final headers = await _getHeaders();
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

  // 2. POST: Daftarkan Personel Baru
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

  // 4. DELETE: Hapus Personel
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