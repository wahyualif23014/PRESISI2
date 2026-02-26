import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Wajib Import Ini
import '../model/recap_model.dart'; 

class RecapRepo {
  final String baseUrl = "http://192.168.100.195:8080/api/rekapitulasi";
  
  // Instance Storage untuk mengambil Token
  final _storage = const FlutterSecureStorage();

  // Helper: Ambil Token
  Future<String> _getToken() async {
    // Gunakan key 'jwt_token' agar konsisten dengan Login
    String? token = await _storage.read(key: 'jwt_token');
    return token ?? '';
  }

  // 1. GET DATA REKAPITULASI (UI)
  Future<List<RecapModel>> getRecapData() async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse(baseUrl),
        // FIX: Tambahkan Header Authorization
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Handle response JSON wrapper (sesuai format backend: { "status": "success", "data": [...] })
        final Map<String, dynamic> body = jsonDecode(response.body);
        
        // Cek apakah data ada di dalam key 'data'
        final List<dynamic> data = body['data'] ?? []; 
        
        return data
            .map((json) => RecapModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
         throw Exception("Sesi habis (401). Silakan Login ulang.");
      } else {
        throw Exception("HTTP ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Kesalahan Koneksi: $e");
    }
  }

  // 2. DOWNLOAD EXCEL
  Future<String?> downloadExcel() async {
    try {
      final token = await _getToken(); // Ambil token dulu
      
      final dio = Dio();

      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 15);
      
      // FIX: Tambahkan Header Token ke Dio agar bisa download file dari route protected
      dio.options.headers['Authorization'] = 'Bearer $token';

      dio.options.headers = {'Authorization': 'Bearer $token'};

      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String fileName =
          "Rekap_Presisi_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      
      // Pastikan directory tidak null
      String savePath;
      if (directory != null) {
         savePath = "${directory.path}/$fileName";
      } else {
         return null; 
      }

      // Download dari endpoint /export
      final response = await dio.download("$baseUrl/export", savePath);

      if (response.statusCode == 200) {
        return savePath;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}