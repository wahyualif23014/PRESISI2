import 'dart:convert';
import 'dart:io';
import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// IMPORT UserModel DARI AUTH


class PersonelService {
<<<<<<< HEAD
  final String baseUrl = 'http://10.16.1.116:8080'; 
=======
  // Ganti baseUrl sesuai config Anda
  final String baseUrl = 'http://10.16.1.87:8080'; 
>>>>>>> fitur-fajri
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- GET ALL (Return List<UserModel>) ---
  Future<List<UserModel>> getAllPersonel() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'), // Endpoint GET All Users
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        
        // Mapping ke UserModel
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      rethrow;
    }
  }

  // --- ADD PERSONEL ---
  Future<void> addPersonel(UserModel user, String password) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/users'),
        headers: headers,
        body: jsonEncode({
          "nama_lengkap": user.namaLengkap,
          "id_tugas": user.idTugas, // Konsisten ID TUGAS
          "username": user.username,
          "id_jabatan": user.idJabatan, // Kirim ID Jabatan (int)
          "role": user.role, // Kirim string '1', '2', '3'
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
        Uri.parse('$baseUrl/admin/users/${user.id}'),
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
        Uri.parse('$baseUrl/admin/users/$id'),
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