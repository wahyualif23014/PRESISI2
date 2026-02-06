import 'dart:convert';
import 'dart:io';
import 'package:KETAHANANPANGAN/features/admin/personnel/data/model/role_enum.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/personel_model.dart'; // Pastikan path import model benar

class PersonelService {
  final String baseUrl = 'http://10.16.9.44:8080'; 
  final _storage = const FlutterSecureStorage();

  // Helper untuk mengambil Token Header
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- GET ALL PERSONEL (GET /admin/users) ---
  Future<List<Personel>> getAllPersonel() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data']; // Backend Go membungkus data dalam key "data"
        
        return data.map((json) => Personel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // --- ADD PERSONEL (POST /admin/users) ---
  Future<void> addPersonel(Personel personel, String password) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/users'),
        headers: headers,
        body: jsonEncode({
          "nama_lengkap": personel.namaLengkap,
          "nrp": personel.nrp,
          "jabatan": personel.jabatan,
          "role": personel.role.label, // Mengirim string 'admin', 'polsek', dll
          "no_telp": personel.noTelp,
          "password": password, // Password wajib dikirim saat create
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

  // --- UPDATE PERSONEL (PUT /admin/users/:id) ---
  Future<void> updatePersonel(Personel personel) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/${personel.id}'),
        headers: headers,
        body: jsonEncode({
          "nama_lengkap": personel.namaLengkap,
          "jabatan": personel.jabatan,
          "role": personel.role.label,
          "no_telp": personel.noTelp,
          // NRP biasanya tidak diupdate sembarangan, tapi jika perlu bisa ditambahkan
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

  // --- DELETE PERSONEL (DELETE /admin/users/:id) ---
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

  // --- SEARCH (Client Side Filtering) ---
  // Karena backend GetUsers mengembalikan semua data, kita filter di sisi Flutter saja agar cepat
  Future<List<Personel>> searchPersonel(String keyword, List<Personel> allData) async {
    if (keyword.isEmpty) return allData;
    
    final query = keyword.toLowerCase();
    return allData.where((p) {
      return p.namaLengkap.toLowerCase().contains(query) ||
             p.nrp.toLowerCase().contains(query) ||
             p.jabatan.toLowerCase().contains(query);
    }).toList();
  }
}