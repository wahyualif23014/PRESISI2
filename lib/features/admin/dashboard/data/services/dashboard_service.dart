import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../model/dashboard_data_response.dart'; // Sesuaikan dengan nama model Go Anda

class DashboardService {
  final String baseUrl = "http://10.243.68.231:8080/api/dashboard";
  final _storage = const FlutterSecureStorage();

  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  Future<String> _getToken() async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      return token ?? '';
    } catch (e) {
      debugPrint("Error reading token: $e");
      return '';
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Mengambil data dashboard lengkap dengan filter opsional
  Future<DashboardDataResponse?> getDashboardData({
    String? resor,
    String? sektor,
    String? idJenisLahan,
    String? idKomoditi,
    String? tahun,
    String? kwartal,
    String? tglMulai,
    String? tglSelesai,
  }) async {
    try {
      // Mapping query parameters sesuai dengan Controller Go
      final queryParams = <String, String>{
        if (resor != null) 'resor': resor,
        if (sektor != null) 'sektor': sektor,
        if (idJenisLahan != null) 'id_jenis_lahan': idJenisLahan,
        if (idKomoditi != null) 'id_komoditi': idKomoditi,
        if (tahun != null) 'tahun': tahun,
        if (kwartal != null) 'kwartal': kwartal,
        if (tglMulai != null) 'tanggal_mulai': tglMulai,
        if (tglSelesai != null) 'tanggal_selesai': tglSelesai,
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        if (body['status'] == 'success') {
          return DashboardDataResponse.fromJson(body['data']);
        }
      }
      
      debugPrint("Dashboard API Error: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      debugPrint("Exception Dashboard Service: $e");
      throw Exception('Gagal memuat data dashboard: $e');
    }
  }
}

class HttpException implements Exception {
  final String message;
  final Uri? uri;
  HttpException(this.message, {this.uri});
  @override
  String toString() => 'HttpException: $message';
}