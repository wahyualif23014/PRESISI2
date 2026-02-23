import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lahan_history_model.dart';

class LandHistoryRepository {
  final String baseUrl = "http://10.16.11.26:8080/api/riwayat-lahan";

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // AMBIL OPSI FILTER DARI DB
  Future<Map<String, List<String>>> getFilterOptions({
    String? polres,
    String? polsek,
  }) async {
    String url = '$baseUrl/filter-options?';
    if (polres != null) url += 'polres=$polres&';
    if (polsek != null) url += 'polsek=$polsek';

    try {
      final response = await http.get(Uri.parse(url));
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
    String url = '$baseUrl/list?search=$keyword';

    if (filters != null) {
      if (filters['polres']?.isNotEmpty ?? false)
        url += '&polres=${filters['polres']}';
      if (filters['polsek']?.isNotEmpty ?? false)
        url += '&polsek=${filters['polsek']}';
      if (filters['jenis_lahan']?.isNotEmpty ?? false)
        url += '&jenis_lahan=${filters['jenis_lahan']}';
      if (filters['komoditas']?.isNotEmpty ?? false)
        url += '&komoditas=${filters['komoditas']}';
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
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
