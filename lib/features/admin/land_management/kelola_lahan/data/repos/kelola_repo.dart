import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/kelola_mode.dart';

class LandManagementRepository {
  final String baseUrl = "http://10.16.7.160:8080/api/kelola-lahan";
  final _storage = const FlutterSecureStorage();

  // Mendapatkan token JWT dari storage lokal
  Future<String> _getToken() async {
    String? token = await _storage.read(key: 'jwt_token');
    return token ?? '';
  }

  // Helper untuk membuat header HTTP dengan otentikasi
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // 1. GET FILTER OPTIONS
  // Mengambil daftar Polres, Polsek, Jenis Lahan, dan Komoditas untuk dropdown filter
  Future<Map<String, dynamic>> getFilterOptions({
    String? polres,
    String? polsek,
  }) async {
    String url = '$baseUrl/filters?';
    if (polres != null && polres.isNotEmpty) {
      url += 'polres=${Uri.encodeComponent(polres)}&';
    }
    if (polsek != null && polsek.isNotEmpty) {
      url += 'polsek=${Uri.encodeComponent(polsek)}';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'] ?? {};
        return {
          'polres': List<String>.from(data['polres'] ?? []),
          'polsek': List<String>.from(data['polsek'] ?? []),
          'jenis_lahan': List<String>.from(data['jenis_lahan'] ?? []),
          'komoditas': List<String>.from(data['komoditas'] ?? []),
        };
      }
      return {};
    } catch (e) {
      debugPrint("Error fetching filter options: $e");
      return {};
    }
  }

  // 2. GET SUMMARY STATS
  // Mengambil data ringkasan total luas potensi, tanam, panen, dan serapan
  Future<LandManagementSummaryModel> getSummaryStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/summary'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Memastikan parsing menggunakan data ['data'] jika API membungkusnya
        return LandManagementSummaryModel.fromJson(data['data'] ?? data);
      } else {
        return _emptySummary();
      }
    } catch (e) {
      debugPrint("Error summary: $e");
      return _emptySummary();
    }
  }

  // Helper untuk data kosong agar UI tidak error saat gagal fetch
  LandManagementSummaryModel _emptySummary() {
    return LandManagementSummaryModel(
      totalPotensiLahan: 0.0,
      totalTanamLahan: 0.0,
      totalPanenLahanHa: 0.0,
      totalPanenLahanTon: 0.0,
      totalSerapanTon: 0.0,
    );
  }

  // 3. GET LIST DATA
  // Mengambil daftar pengelolaan lahan berdasarkan keyword pencarian dan filter aktif
  Future<List<LandManagementItemModel>> getLandManagementList({
    String keyword = "",
    Map<String, String>? filters,
  }) async {
    String url = '$baseUrl?search=${Uri.encodeComponent(keyword)}';

    if (filters != null) {
      if (filters['polres'] != null && filters['polres']!.isNotEmpty) {
        url += '&polres=${Uri.encodeComponent(filters['polres']!)}';
      }
      if (filters['polsek'] != null && filters['polsek']!.isNotEmpty) {
        url += '&polsek=${Uri.encodeComponent(filters['polsek']!)}';
      }
      if (filters['jenis_lahan'] != null &&
          filters['jenis_lahan']!.isNotEmpty) {
        url += '&jenis_lahan=${Uri.encodeComponent(filters['jenis_lahan']!)}';
      }
      if (filters['komoditas'] != null && filters['komoditas']!.isNotEmpty) {
        url += '&komoditas=${Uri.encodeComponent(filters['komoditas']!)}';
      }
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => LandManagementItemModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error repo list: $e");
      return [];
    }
  }

  // 4. DELETE DATA
  // Menghapus data lahan berdasarkan ID
  Future<bool> deleteLahan(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error delete: $e");
      return false;
    }
  }

  // 5. UPDATE DATA TANAM
  // Memperbarui data tanam (tanggal tanam, bibit, dll) untuk lahan tertentu
  Future<bool> updateTanam(String idLahan, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$idLahan/tanam'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );

      // Menganggap berhasil jika status 200 OK
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error update tanam: $e");
      return false;
    }
  }
}
