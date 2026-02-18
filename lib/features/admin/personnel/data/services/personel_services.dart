import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Import Master Model dari folder Auth agar konsisten
import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:KETAHANANPANGAN/auth/models/role_enum.dart';

class PersonelService {
  final String baseUrl = 'http://10.16.2.233:8080'; 

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token'); 
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- GET ALL PERSONEL ---
  Future<List<UserModel>> getAllPersonel() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/users'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      throw Exception('Gagal memuat data personel');
    } catch (e) {
      rethrow;
    }
  }

  // --- ADD PERSONEL (IAM: Admin Registration) ---
  Future<void> addPersonel(UserModel user, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/admin/users'),
        headers: await _getHeaders(),
        body: jsonEncode({
          "nama_lengkap": user.namaLengkap,
          "id_tugas": user.idTugas,
          "username": user.nrp, // Map NRP ke 'username' sesuai Backend Go
          "id_jabatan": user.jabatanDetail?.id, 
          "password": password,
          "role": user.role.value, // Kirim string '1','2','3'
          "no_telp": user.noTelp,
        }),
      );

      if (response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Gagal menambah personel');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- UPDATE PERSONEL (Partial Update) ---
  Future<void> updatePersonel(UserModel user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/users/${user.id}'),
        headers: await _getHeaders(),
        body: jsonEncode({
          "nama_lengkap": user.namaLengkap,
          "no_telp": user.noTelp,
          "id_tugas": user.idTugas,
          "id_jabatan": user.jabatanDetail?.id,
          "role": user.role.value,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Gagal memperbarui data');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- DELETE PERSONEL ---
  Future<void> deletePersonel(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/users/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus personel');
      }
    } catch (e) {
      rethrow;
    }
  }
}