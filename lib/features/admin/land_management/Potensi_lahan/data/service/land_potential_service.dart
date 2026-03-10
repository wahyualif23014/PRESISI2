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

  Future<String> _getToken() async {
    String? token = await _storage.read(key: 'jwt_token');
    return token ?? '';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer ' + token,
    };
  }

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
      debugPrint("Error Fetch Data: " + e.toString());
      return [];
    }
  }

  Future<Map<String, List<String>>> fetchFilterOptions({String? polres}) async {
    try {
      String url = baseUrl + "/filter-options";
      if (polres != null && polres.isNotEmpty) {
        url += "?polres=" + Uri.encodeComponent(polres);
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
      debugPrint("Error Filter Options: " + e.toString());
      return {"polres": [], "polsek": [], "jenis_lahan": [], "komoditas": []};
    }
  }

  Future<bool> postLandData(LandPotentialModel data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
        body: json.encode(data.toJson()),
      );

      debugPrint("Post Response: " + response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['status'] != 'error' && body['status'] != 'failed';
      }
      return false;
    } catch (e) {
      debugPrint("Error Post: " + e.toString());
      return false;
    }
  }

  Future<bool> updateLandData(String id, LandPotentialModel data) async {
    try {
      final response = await http.put(
        Uri.parse(baseUrl + "/" + id),
        headers: await _getHeaders(),
        body: json.encode(data.toJson()),
      );

      debugPrint("Update Response: " + response.body);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['status'] != 'error' && body['status'] != 'failed';
      }
      return false;
    } catch (e) {
      debugPrint("Error Update: " + e.toString());
      return false;
    }
  }

  Future<bool> deleteLandData(String id) async {
    try {
      final response = await http.delete(
        Uri.parse(baseUrl + "/" + id),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Delete: " + e.toString());
      return false;
    }
  }

  Future<LandSummaryModel?> fetchSummaryData() async {
    try {
      final headers = await _getHeaders();
      final results = await Future.wait([
        http.get(Uri.parse(baseUrl + "/summary"), headers: headers),
        http.get(Uri.parse(baseUrl + "/no-potential"), headers: headers),
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
      debugPrint("Error Fetch Summary: " + e.toString());
      return null;
    }
  }

  Future<NoLandPotentialModel?> fetchNoLandData() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl + "/no-potential"),
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
      debugPrint("Error Fetch No Land Data: " + e.toString());
      return null;
    }
  }

  Future<bool> toggleValidation(int landId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      final response = await http.post(
        Uri.parse(baseUrl + '/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + token,
        },
        body: jsonEncode({
          'id_lahan': landId,
          'idlahan': landId,
          'id': landId,
          'id_lahan_string': landId.toString(),
        }),
      );

      debugPrint("Validate Response: " + response.body);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['status'] != 'error' && body['status'] != 'failed';
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error Validate: " + e.toString());
      return false;
    }
  }
}
