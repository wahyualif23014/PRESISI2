import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:KETAHANANPANGAN/core/api/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminService {

  final String baseUrl = 'http://192.168.1.76:8080'; 
  final _storage = const FlutterSecureStorage();

  // ===============================
  // PRIVATE: Ambil Header dengan JWT
  // ===============================
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('Sesi berakhir. Silakan login ulang.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ===============================
  // 1. GET: Ambil Semua User
  // ===============================
  Future<List<dynamic>> getUsers() async {
    final headers = await _getHeaders();

    final response = await ApiClient
        .get(Uri.parse('$baseUrl/api/admin/users'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      // Jaga-jaga kalau format beda
      if (json is Map && json.containsKey('data')) {
        return json['data'];
      } else {
        return [];
      }
    }

    if (response.statusCode == 401) {
      throw Exception('Token tidak valid atau sudah kadaluarsa.');
    }

    throw Exception('Gagal memuat data user (${response.statusCode})');
  }

  // ===============================
  // 2. POST: Buat User Baru
  // ===============================
  Future<void> createUser(Map<String, dynamic> userData) async {
    final headers = await _getHeaders();

    final response = await ApiClient
        .post(
          Uri.parse('$baseUrl/api/admin/users'),
          headers: headers,
          body: jsonEncode(userData),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 201) return;

    if (response.statusCode == 401) {
      throw Exception('Token tidak valid atau sudah kadaluarsa.');
    }

    try {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? errorData['message'] ?? response.body);
    } catch (_) {
      throw Exception('Gagal mendaftarkan personel: ${response.statusCode} - ${response.body}');
    }
  }
  
  // --- FETCH LIST JABATAN (Dropdown) ---
  Future<List<dynamic>> getJabatanList() async {
    final headers = await _getHeaders();
    final response = await ApiClient.get(
      Uri.parse('$baseUrl/api/admin/jabatan/list'),
      headers: headers
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }
    throw Exception('Gagal memuat list jabatan');
  }

  // --- FETCH LIST TINGKAT/UNIT (Dropdown) ---
  Future<List<dynamic>> getTingkatList() async {
    final headers = await _getHeaders();
    final response = await ApiClient.get(
      Uri.parse('$baseUrl/api/admin/tingkat/list'), 
      headers: headers
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'] ?? [];
    }
    throw Exception('Gagal memuat list tingkat');
  }

  // ===============================
  // 3. PUT: Update User
  // ===============================
  Future<void> updateUser(int id, Map<String, dynamic> userData) async {
    final headers = await _getHeaders();

    final response = await ApiClient
        .put(
          Uri.parse('$baseUrl/api/admin/users/$id'),
          headers: headers,
          body: jsonEncode(userData),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) return;

    if (response.statusCode == 401) {
      throw Exception('Token tidak valid atau sudah kadaluarsa.');
    }

    throw Exception('Gagal memperbarui data personel (${response.statusCode})');
  }

  // ===============================
  // 4. DELETE: Hapus User
  // ===============================
  Future<void> deleteUser(int id) async {
    final headers = await _getHeaders();

    final response = await ApiClient
        .delete(Uri.parse('$baseUrl/api/admin/users/$id'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) return;

    if (response.statusCode == 401) {
      throw Exception('Token tidak valid atau sudah kadaluarsa.');
    }

    throw Exception('Gagal menghapus personel (${response.statusCode})');
  }
}
