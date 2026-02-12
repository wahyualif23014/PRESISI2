import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/models/position_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Import Model

class JabatanService {
  // Ganti URL ini sesuai IP Backend GO Anda
  static const String baseUrl = "http://10.16.15.78:8080"; 
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- 1. GET ALL DATA ---
  Future<List<JabatanModel>> getJabatanList() async {
    final url = Uri.parse("$baseUrl/jabatan");
    
    try {
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        // Convert List JSON ke List<JabatanModel>
        return data.map((e) => JabatanModel.fromJson(e)).toList();
      } else {
        throw Exception("Gagal memuat data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error Service Jabatan: $e");
      rethrow; 
    }
  }

  // --- 2. CREATE (TAMBAH DATA) ---
  Future<bool> createJabatan(String namaJabatan, String? idAnggota) async {
    final url = Uri.parse("$baseUrl/jabatan");

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          "nama_jabatan": namaJabatan,
          "id_anggota": idAnggota != null ? int.tryParse(idAnggota) : null,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Error Create Jabatan: $e");
      return false;
    }
  }

  // --- 3. UPDATE (EDIT DATA) ---
  Future<bool> updateJabatan(String id, String namaJabatan, String? idAnggota) async {
    final url = Uri.parse("$baseUrl/jabatan/$id");

    try {
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          "nama_jabatan": namaJabatan,
          "id_anggota": idAnggota != null ? int.tryParse(idAnggota) : null,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Update Jabatan: $e");
      return false;
    }
  }

  // --- 4. DELETE (HAPUS DATA) ---
  Future<bool> deleteJabatan(String id) async {
    final url = Uri.parse("$baseUrl/jabatan/$id");

    try {
      final response = await http.delete(url, headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Delete Jabatan: $e");
      return false;
    }
  }
}