import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../model/land_potential_model.dart';
import '../model/land_summary_model.dart';
import '../model/no_land_potential_model.dart';

class LandPotentialService {
  final String baseUrl = "http://10.16.14.46:8080/api/potensi-lahan";
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

  // Mengambil data wilayah secara dinamis (Polres, Polsek, atau Desa)
  // Mengembalikan List of Map agar bisa menyimpan Nama dan Kode wilayah
  Future<List<Map<String, dynamic>>> fetchDynamicWilayah({
    String? polres,
    String? polsek,
  }) async {
    try {
      Map<String, String> qParams = {};
      if (polres != null) qParams['polres'] = polres;
      if (polsek != null) qParams['polsek'] = polsek;

      final uri = Uri.parse(
        "$baseUrl/filter-options",
      ).replace(queryParameters: qParams);
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          final data = body['data'];

          if (polsek != null) {
            return List<Map<String, dynamic>>.from(data['desa'] ?? []);
          }
          if (polres != null) {
            return List<Map<String, dynamic>>.from(data['polsek'] ?? []);
          }
          return List<Map<String, dynamic>>.from(data['polres'] ?? []);
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error Fetch Wilayah: $e");
      return [];
    }
  }

  // Mengambil daftar komoditi dari endpoint filter-options
  Future<List<Map<String, dynamic>>> fetchKomoditiOptions() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/filter-options"),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return List<Map<String, dynamic>>.from(body['data']['komoditi'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint("Error Fetch Komoditi: $e");
      return [];
    }
  }

  // Mengambil data utama potensi lahan dengan filter dan pagination
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
      final response = await http.get(uri, headers: await _getHeaders());

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
      debugPrint("Error Fetch Land Data: $e");
      return [];
    }
  }

  // Mengambil data statistik wilayah yang belum memiliki potensi lahan
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
      debugPrint("Error Fetch No Land Data: $e");
      return null;
    }
  }

  // Mengirim data lahan baru ke server
  Future<bool> postLandData(LandPotentialModel data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
        body: json.encode(data.toJson()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Post Data: $e");
      return false;
    }
  }

  // Memperbarui data lahan yang sudah ada
  Future<bool> updateLandData(String id, LandPotentialModel data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: await _getHeaders(),
        body: json.encode(data.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Update Data: $e");
      return false;
    }
  }

  // Menghapus data lahan berdasarkan ID
  Future<bool> deleteLandData(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Delete Data: $e");
      return false;
    }
  }

  // Mengambil ringkasan statistik lahan (Luas, Jumlah lokasi, dll)
  Future<LandSummaryModel?> fetchSummaryData() async {
    try {
      final headers = await _getHeaders();
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

        if (noPotentialRes.statusCode == 200) {
          final noPotentialBody = json.decode(noPotentialRes.body);
          if (noPotentialBody['status'] == 'success') {
            combinedData['details'] = noPotentialBody['data']['details'];
          }
        }
        return LandSummaryModel.fromJson(combinedData);
      }
      return null;
    } catch (e) {
      debugPrint("Error Fetch Summary: $e");
      return null;
    }
  }

  // Mengubah status validasi lahan (Validasi/Batal Validasi)
  Future<bool> toggleValidation(int landId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/validate"),
        headers: await _getHeaders(),
        body: jsonEncode({'id_lahan': landId}),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error Toggle Validation: $e");
      return false;
    }
  }
}
