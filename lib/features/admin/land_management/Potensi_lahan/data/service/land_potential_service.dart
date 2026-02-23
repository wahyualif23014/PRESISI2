import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/land_potential_model.dart';
import '../model/land_summary_model.dart';
import '../model/no_land_potential_model.dart';

class LandPotentialService {
  // Gunakan IP server yang sesuai dengan konfigurasi backend Go kamu
  final String baseUrl = "http://192.168.100.195:8080/api/potensi-lahan";

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // 1. Ambil List Data dengan Filter Aktif
  Future<List<LandPotentialModel>> fetchLandData({
    String search = '',
    String status = '',
    String? polres,
    String? polsek,
    String? jenisLahan,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      Map<String, String> qParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search.isNotEmpty) qParams['search'] = search;
      if (status.isNotEmpty) qParams['status'] = status;
      if (polres != null && polres.isNotEmpty) qParams['polres'] = polres;
      if (polsek != null && polsek.isNotEmpty) qParams['polsek'] = polsek;
      if (jenisLahan != null && jenisLahan.isNotEmpty) {
        qParams['jenis_lahan'] = jenisLahan;
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: qParams);
      final headers = await _getHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return (data['data'] as List)
              .map((x) => LandPotentialModel.fromJson(x))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error Fetch Data: ${e.toString()}");
      return [];
    }
  }

  // 2. Ambil Opsi Filter (Cascading Polres/Polsek)
  Future<Map<String, List<String>>> fetchFilterOptions({String? polres}) async {
    try {
      String url = "$baseUrl/filters";
      if (polres != null && polres.isNotEmpty) {
        url += "?polres=${Uri.encodeComponent(polres)}";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          final data = body['data'];
          return {
            "polres": List<String>.from(data['polres'] ?? []),
            "polsek": List<String>.from(data['polsek'] ?? []),
            "jenis_lahan": List<String>.from(data['jenis_lahan'] ?? []),
            "komoditas": List<String>.from(data['komoditas'] ?? []),
          };
        }
      }
      return {"polres": [], "polsek": [], "jenis_lahan": [], "komoditas": []};
    } catch (e) {
      debugPrint("Error Filter Options: ${e.toString()}");
      return {"polres": [], "polsek": [], "jenis_lahan": [], "komoditas": []};
    }
  }

  // 3. Tambah Data Baru
  Future<bool> postLandData(LandPotentialModel data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
        body: json.encode(data.toJson()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Post: ${e.toString()}");
      return false;
    }
  }

  // 4. Update Data Lahan Berdasarkan ID
  Future<bool> updateLandData(String id, LandPotentialModel data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: await _getHeaders(),
        body: json.encode(data.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Update: ${e.toString()}");
      return false;
    }
  }

  // 5. Hapus Data Lahan Berdasarkan ID
  Future<bool> deleteLandData(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Delete: ${e.toString()}");
      return false;
    }
  }

  // 6. Ambil Data Summary Lengkap (Menggabungkan Data Luas dan Data Wilayah Kosong)
  Future<LandSummaryModel?> fetchSummaryData() async {
    try {
      final headers = await _getHeaders();

      // Mengambil data dari dua endpoint secara paralel untuk efisiensi
      final results = await Future.wait([
        http.get(Uri.parse("$baseUrl/summary"), headers: headers),
        http.get(Uri.parse("$baseUrl/no-potential"), headers: headers),
      ]);

      final summaryRes = results[0];
      final noPotentialRes = results[1];

      if (summaryRes.statusCode == 200) {
        final summaryBody = json.decode(summaryRes.body);
        Map<String, dynamic> combinedData = Map<String, dynamic>.from(
          summaryBody['data'],
        );

        // Jika data wilayah kosong berhasil diambil, masukkan ke dalam objek data utama
        if (noPotentialRes.statusCode == 200) {
          final noPotentialBody = json.decode(noPotentialRes.body);
          if (noPotentialBody['status'] == 'success') {
            // PENTING: Masukkan ke key 'details' sesuai struktur model di atas
            combinedData['details'] = noPotentialBody['data']['details'];
          }
        }

        return LandSummaryModel.fromJson(combinedData);
      }
      return null;
    } catch (e) {
      debugPrint("Error Fetch Combined Summary: ${e.toString()}");
      return null;
    }
  }

  // 7. Ambil Data Wilayah yang Belum Memiliki Potensi Saja
  Future<NoLandPotentialModel?> fetchNoLandData() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/no-potential"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          return NoLandPotentialModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error Fetch No Land Data: ${e.toString()}");
      return null;
    }
  }
}
