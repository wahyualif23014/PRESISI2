import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/polres_model.dart';
import '../models/polsek_model.dart';
import '../models/wilayah_model.dart';

class UnitService {
  // Sesuaikan IP dengan Backend Golang Anda
  final String baseUrl = 'http://10.16.15.29:8080'; // Emulator Android
  
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- GET WILAYAH ---
  Future<List<WilayahModel>> getWilayah() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/wilayah'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      return data.map((e) => WilayahModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal load wilayah: ${response.statusCode}');
    }
  }

  // --- GET POLRES ---
  Future<List<PolresModel>> getPolres() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/polres'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      return data.map((e) => PolresModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal load polres: ${response.statusCode}');
    }
  }

  // --- GET POLSEK ---
  Future<List<PolsekModel>> getPolsek() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/polsek'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      return data.map((e) => PolsekModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal load polsek: ${response.statusCode}');
    }
  }

  // --- CREATE DATA (Contoh untuk Polres) ---
  Future<void> addPolres(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/polres'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menambah polres');
    }
  }

  // Tambahkan createPolsek & createWilayah dengan pola yang sama...
}