import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/land_potential_model.dart';

class LandPotentialService {
  // GANTI IP INI SESUAI SERVER KAMU
  // Pastikan tidak pakai localhost jika di Emulator/HP
  final String baseUrl = "http://10.16.9.254:8080/api/potensi-lahan";

  // ==========================================
  // 1. GET DATA (READ) + FILTER + PAGINATION
  // ==========================================
  Future<List<LandPotentialModel>> fetchLandData({
    String search = '',
    String status = '',
    String? polres,
    String? polsek,
    String? jenisLahan,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Siapkan Parameter Query
      Map<String, String> qParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search.isNotEmpty) qParams['search'] = search;
      if (status.isNotEmpty) qParams['status'] = status;
      if (polres != null && polres.isNotEmpty) qParams['polres'] = polres;
      if (polsek != null && polsek.isNotEmpty) qParams['polsek'] = polsek;
      if (jenisLahan != null && jenisLahan.isNotEmpty)
        qParams['jenis_lahan'] = jenisLahan;

      final uri = Uri.parse(baseUrl).replace(queryParameters: qParams);

      print("Requesting: $uri"); // Debugging URL

      final response = await http.get(uri);

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
      print("Error Fetch: $e");
      return [];
    }
  }

  // ==========================================
  // 2. GET FILTER OPTIONS (DROPDOWN)
  // ==========================================
  Future<Map<String, List<String>>> fetchFilterOptions() async {
    try {
      final uri = Uri.parse("$baseUrl/filters");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          final data = body['data'];
          return {
            "polres": List<String>.from(data['polres'] ?? []),
            "polsek": List<String>.from(data['polsek'] ?? []),
          };
        }
      }
      return {"polres": [], "polsek": []};
    } catch (e) {
      print("Error Filter Options: $e");
      return {"polres": [], "polsek": []};
    }
  }

  // ==========================================
  // 3. POST DATA (CREATE) - INI YANG TADI ERROR
  // ==========================================
  Future<bool> postLandData(LandPotentialModel data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data.toJson()),
      );

      // Backend Go biasanya return 201 Created
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error Post: $e");
      return false;
    }
  }

  // ==========================================
  // 4. PUT DATA (UPDATE/EDIT)
  // ==========================================
  Future<bool> updateLandData(String id, LandPotentialModel data) async {
    try {
      final uri = Uri.parse("$baseUrl/$id");
      final response = await http.put(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode(data.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error Update: $e");
      return false;
    }
  }

  // ==========================================
  // 5. DELETE DATA (HAPUS)
  // ==========================================
  Future<bool> deleteLandData(String id) async {
    try {
      final uri = Uri.parse("$baseUrl/$id");
      final response = await http.delete(uri);

      return response.statusCode == 200;
    } catch (e) {
      print("Error Delete: $e");
      return false;
    }
  }
}
