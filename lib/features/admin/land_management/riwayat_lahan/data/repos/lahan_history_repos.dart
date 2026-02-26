import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/lahan_history_model.dart';

class LandHistoryRepository {
  final String baseUrl = "http://192.168.100.196:8080/api/riwayat-lahan";
  final _storage = const FlutterSecureStorage();

  Future<String> _getToken() async {
    // FIX: Gunakan SecureStorage dan key 'jwt_token' agar konsisten
    String? token = await _storage.read(key: 'jwt_token');
    return token ?? '';
  }

  // AMBIL OPSI FILTER DARI DB
  Future<Map<String, List<String>>> getFilterOptions({
    String? polres,
    String? polsek,
  }) async {
    String url = '$baseUrl/filter-options?';
    if (polres != null && polres.isNotEmpty) url += 'polres=${Uri.encodeComponent(polres)}&';
    if (polsek != null && polsek.isNotEmpty) url += 'polsek=${Uri.encodeComponent(polsek)}';

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
        final data = jsonDecode(response.body);
        return {
          'polres': List<String>.from(data['polres'] ?? []),
          'polsek': List<String>.from(data['polsek'] ?? []),
          'jenis_lahan': List<String>.from(data['jenis_lahan'] ?? []),
          'komoditas': List<String>.from(data['komoditas'] ?? []),
        };
      }
    } catch (e) {
      debugPrint("Error Filter Options: $e");
    }
    return {};
  }

  Future<List<LandHistoryItemModel>> getHistoryList({
    String keyword = "",
    Map<String, String>? filters,
  }) async {
    final token = await _getToken();
    
    // FIX: Hapus '/list', langsung ke endpoint root grup riwayat
    String url = '$baseUrl?search=${Uri.encodeComponent(keyword)}';

    if (filters != null) {
      if (filters['polres']?.isNotEmpty ?? false) {
        url += '&polres=${Uri.encodeComponent(filters['polres']!)}';
      }
      if (filters['polsek']?.isNotEmpty ?? false) {
        url += '&polsek=${Uri.encodeComponent(filters['polsek']!)}';
      }
      if (filters['jenis_lahan']?.isNotEmpty ?? false) {
        url += '&jenis_lahan=${Uri.encodeComponent(filters['jenis_lahan']!)}';
      }
      if (filters['komoditas']?.isNotEmpty ?? false) {
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
        return data.map((e) => LandHistoryItemModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error Fetch History: $e");
    }
    return [];
  }
}