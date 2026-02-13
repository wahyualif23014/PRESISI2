import 'dart:convert';
import 'dart:io';
import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // GANTI KE SINI

class PersonelService {
  final String baseUrl = 'http://10.16.7.228:8080'; 

  Future<Map<String, String>> _getHeaders() async {
    // AMBIL DARI SharedPreferences agar sinkron dengan AuthProvider
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token'); 
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- GET ALL ---
  Future<List<UserModel>> getAllPersonel() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/users'), // Tambahkan prefix /api
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- ADD PERSONEL ---
  Future<void> addPersonel(UserModel user, String password) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/users'), // Tambahkan prefix /api
        headers: headers,
        body: jsonEncode({
          "nama_lengkap": user.namaLengkap,
          "id_tugas": user.idTugas,
          "username": user.username,
          "id_jabatan": user.idJabatan,
          "role": user.role,
          "no_telp": user.noTelp,
          "password": password, 
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Gagal menambah personel');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- UPDATE PERSONEL ---
  Future<void> updatePersonel(UserModel user) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/users/${user.id}'), // Tambahkan prefix /api
        headers: headers,
        body: jsonEncode({
          "nama_lengkap": user.namaLengkap,
          "id_tugas": user.idTugas,
          "username": user.username,
          "id_jabatan": user.idJabatan,
          "role": user.role,
          "no_telp": user.noTelp,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Gagal update personel');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- DELETE PERSONEL ---
  Future<void> deletePersonel(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/users/$id'), // Tambahkan prefix /api
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus personel');
      }
    } catch (e) {
      rethrow;
    }
  }
}