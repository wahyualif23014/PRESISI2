import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/recap_model.dart';

class RecapRepo {
  final String baseUrl = "http://192.168.100.195:8080/api/rekapitulasi";
  final String filterUrl =
      "http://192.168.100.195:8080/api/riwayat-lahan/filter-options";
  final _storage = const FlutterSecureStorage();

  Future<String> _getToken() async {
    String? token = await _storage.read(key: 'jwt_token');
    return token ?? '';
  }

  // 1. AMBIL OPSI FILTER DARI BACKEND
  Future<Map<String, List<String>>> getFilterOptions({String? polres}) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse(filterUrl).replace(
        queryParameters: {
          if (polres != null && polres.isNotEmpty) "polres": polres,
        },
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] ?? {};
        return {
          'polres': List<String>.from(data['polres'] ?? []),
          'polsek': List<String>.from(data['polsek'] ?? []),
          'jenis_lahan': List<String>.from(data['jenis_lahan'] ?? []),
          'komoditi': List<String>.from(data['komoditi'] ?? []),
        };
      }
    } catch (e) {
      debugPrint("Error Get Options: $e");
    }
    return {'polres': [], 'polsek': [], 'jenis_lahan': [], 'komoditi': []};
  }

  // 2. GET DATA DENGAN PARAMETER FILTER
  Future<List<RecapModel>> getRecapData({Map<String, String>? filters}) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse(baseUrl).replace(queryParameters: filters);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        return data.map((json) => RecapModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Sesi habis (401). Silakan Login ulang.");
      } else {
        throw Exception("HTTP ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Kesalahan Koneksi: $e");
    }
  }

  // 3. DOWNLOAD EXCEL DENGAN FILTER AKTIF
  Future<String?> downloadExcel({Map<String, String>? filters}) async {
    try {
      final token = await _getToken();
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      Directory? directory =
          Platform.isAndroid
              ? Directory('/storage/emulated/0/Download')
              : await getApplicationDocumentsDirectory();

      if (Platform.isAndroid && !await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }

      final String savePath =
          "${directory!.path}/Rekap_Presisi_${DateTime.now().millisecondsSinceEpoch}.xlsx";

      final response = await dio.download(
        "$baseUrl/export",
        savePath,
        queryParameters: filters,
      );

      return response.statusCode == 200 ? savePath : null;
    } catch (e) {
      return null;
    }
  }
}
