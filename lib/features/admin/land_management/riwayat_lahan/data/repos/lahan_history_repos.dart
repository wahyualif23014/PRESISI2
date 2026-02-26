import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/lahan_history_model.dart';

class LandHistoryRepository {
  final String baseUrl = "http://192.168.100.195:8080/api/riwayat-lahan";
  final _storage = const FlutterSecureStorage();

  Future<String> _getToken() async {
    return await _storage.read(key: 'jwt_token') ?? '';
  }

  // ==============================
  // GET FILTER OPTIONS (FIXED PROPERLY)
  // ==============================
  Future<Map<String, List<String>>> getFilterOptions({String? polres}) async {
    try {
      final token = await _getToken();

      final uri = Uri.parse('$baseUrl/filter-options').replace(
        queryParameters: {
          if (polres != null && polres.isNotEmpty) "polres": polres,
        },
      );

      debugPrint("Request URI: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] ?? {};

        List<String> parseList(dynamic value) {
          if (value == null) return [];
          if (value is List) {
            return value.map((e) => e.toString()).toList();
          }
          return [];
        }

        return {
          'polres': parseList(data['polres']),
          'polsek': parseList(data['polsek']),
          'jenis_lahan': parseList(data['jenis_lahan']),
          'komoditi': parseList(data['komoditi']),
        };
      }
    } catch (e) {
      debugPrint("Error Filter Options: $e");
    }

    return {'polres': [], 'polsek': [], 'jenis_lahan': [], 'komoditi': []};
  }

  // ==============================
  // GET HISTORY LIST
  // ==============================
  // lahan_history_repos.dart

  Future<List<LandHistoryItemModel>> getHistoryList({
    String keyword = "",
    Map<String, String>? filters,
  }) async {
    try {
      final token = await _getToken();

      // Buat map untuk query parameters
      Map<String, String> queryParams = {};

      if (keyword.isNotEmpty) queryParams["search"] = keyword;

      // Masukkan semua filter dari dialog ke parameter URL
      if (filters != null) {
        filters.forEach((key, value) {
          if (value.isNotEmpty) queryParams[key] = value;
        });
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      debugPrint("Fetching with URL: $uri");

      final response = await http.get(
        uri,
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
