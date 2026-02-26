import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/position_model.dart' show JabatanModel; // Pastikan import ini aktif

class JabatanService {
  static const String baseUrl = "http://192.168.100.195:8080/api/admin/jabatan"; 

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${prefs.getString('jwt_token')}',
    };
  }

  // --- INI FUNGSI YANG KURANG (SOLUSI ERROR) ---
  Future<List<JabatanModel>> getJabatanList() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl), 
        headers: await _getHeaders()
      );

      if (response.statusCode == 200) {
        // Backend Go mengirimkan field "data" berisi array jabatan
        final List data = jsonDecode(response.body)['data'];
        return data.map((e) => JabatanModel.fromJson(e)).toList();
      } else {
        throw Exception("Gagal mengambil data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Koneksi Error: $e");
    }
  }

  // Menambah data baru sesuai binding JSON di Go
  Future<bool> createJabatan(String nama) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _getHeaders(),
      // Sesuai dengan struct input di CreateJabatan (Go)
      body: jsonEncode({"nama_jabatan": nama}), 
    );
    // Go mengembalikan StatusCreated (201)
    return response.statusCode == 201; 
  }

  // Update: Menggunakan ID int sesuai idjabatan (uint64) di Go
  Future<bool> updateJabatan(int id, String nama) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: await _getHeaders(),
      body: jsonEncode({"nama_jabatan": nama}),
    );
    return response.statusCode == 200;
  }

  // Delete: Mengirimkan ID ke endpoint DeleteJabatan
  Future<bool> deleteJabatan(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }
  
}