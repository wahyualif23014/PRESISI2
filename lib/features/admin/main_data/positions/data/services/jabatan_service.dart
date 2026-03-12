import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/position_model.dart' show JabatanModel;

class JabatanService {
  static const String baseUrl = "http://192.168.100.195:8080/api/admin/jabatan";
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  Future<List<JabatanModel>> getJabatanList() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['data'];
        return data.map((e) => JabatanModel.fromJson(e)).toList();
      } else {
        throw Exception("Gagal mengambil data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Koneksi Error: $e");
    }
  }

  Future<bool> createJabatan(String nama) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _getHeaders(),
      body: jsonEncode({"nama_jabatan": nama}),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateJabatan(int id, String nama) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: await _getHeaders(),
      body: jsonEncode({"nama_jabatan": nama}),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteJabatan(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }
}
