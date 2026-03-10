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
        throw Exception("Sesi habis. Silakan Login ulang.");
      } else {
        throw Exception("HTTP ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Kesalahan Koneksi: $e");
    }
  }

  Future<String?> downloadExcel({Map<String, String>? filters}) async {
    try {
      final token = await _getToken();
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      // Gunakan path provider untuk folder yang lebih kompatibel
      Directory? directory;
      if (Platform.isAndroid) {
        // Path folder Download publik
        directory = Directory('/storage/emulated/0/Download');
        // Cek izin akses folder
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String savePath =
          "${directory!.path}/Rekap_Presisi_${DateTime.now().millisecondsSinceEpoch}.xlsx";

      final response = await dio.download(
        "$baseUrl/export",
        savePath,
        queryParameters: filters,
      );

      if (response.statusCode == 200) {
        // PENTING: Untuk Android 11+, file seringkali tertahan di cache
        // Gunakan package 'open_filex' agar user bisa langsung membuka setelah download
        return savePath;
      }
      return null;
    } catch (e) {
      debugPrint("Gagal simpan file: $e");
      return null;
    }
  }
}
