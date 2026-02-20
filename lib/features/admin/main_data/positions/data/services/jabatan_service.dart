import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/models/position_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JabatanService {
  static const String baseUrl = "http://10.16.9.254:8080/api/admin/jabatan"; 

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token'); 
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<JabatanModel>> getJabatanList() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: await _getHeaders());

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((e) => JabatanModel.fromJson(e)).toList();
      } else {
        throw Exception("Gagal memuat data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error Service Jabatan: $e");
      rethrow; 
    }
  }

  Future<bool> createJabatan(String namaJabatan, String? idAnggota) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
        body: jsonEncode({
          "nama_jabatan": namaJabatan,
          "id_anggota": idAnggota != null ? int.tryParse(idAnggota) : null,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateJabatan(String id, String namaJabatan, String? idAnggota) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: await _getHeaders(),
        body: jsonEncode({
          "nama_jabatan": namaJabatan,
          "id_anggota": idAnggota != null ? int.tryParse(idAnggota) : null,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteJabatan(String id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$id"), headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}