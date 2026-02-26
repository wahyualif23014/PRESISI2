import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/kelola_mode.dart';

class LandManagementRepository {
  // Ganti endpoint filter-options ke filters agar sesuai rute grup di main.go
  final String baseUrl = "http://192.168.100.195:8080/api/kelola-lahan";
  final _storage = const FlutterSecureStorage();

  Future<String> _getToken() async {
    String? token = await _storage.read(key: 'jwt_token');
    return token ?? '';
  }

  // ========================================================
  // PERBAIKAN: Ambil data dari key 'data' sesuai format Backend
  // ========================================================
  Future<Map<String, dynamic>> getFilterOptions({
    String? polres,
    String? polsek,
  }) async {
    // Sesuai route backend: /api/kelola-lahan/filters
    String url = '$baseUrl/filters?';
    if (polres != null && polres.isNotEmpty)
      url += 'polres=${Uri.encodeComponent(polres)}&';
    if (polsek != null && polsek.isNotEmpty)
      url += 'polsek=${Uri.encodeComponent(polsek)}';

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Ambil objek 'data' dari response sukses backend
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

  Future<LandManagementSummaryModel> getSummaryStats() async {
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LandManagementSummaryModel.fromJson(data);
      } else {
        return LandManagementSummaryModel(
          totalPotensiLahan: 0,
          totalTanamLahan: 0,
          totalPanenLahanHa: 0,
          totalPanenLahanTon: 0,
          totalSerapanTon: 0,
        );
      }
    } catch (e) {
      return LandManagementSummaryModel(
        totalPotensiLahan: 0,
        totalTanamLahan: 0,
        totalPanenLahanHa: 0,
        totalPanenLahanTon: 0,
        totalSerapanTon: 0,
      );
    }
  }

  Future<List<LandManagementItemModel>> getLandManagementList({
    String keyword = "",
    Map<String, String>? filters,
  }) async {
    final token = await _getToken();

    // Sesuai route backend: /api/kelola-lahan (tanpa /list jika rute kosong di Go)
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
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
}
