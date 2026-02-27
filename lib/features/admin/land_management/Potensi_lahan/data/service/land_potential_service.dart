import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mime/mime.dart';

import '../model/land_potential_model.dart';
import '../model/land_summary_model.dart';
import '../model/no_land_potential_model.dart';

class LandPotentialService {
  // Gunakan IP yang konsisten dengan konfigurasi server Go Anda
  final String baseUrl = "http://192.168.100.196:8080/api/potensi-lahan";
  final String authUrl = "http://192.168.100.196:8080/api/view/profile";
  final _storage = const FlutterSecureStorage();

  static final LandPotentialService _instance = LandPotentialService._internal();
  factory LandPotentialService() => _instance;
  LandPotentialService._internal();

  // ==================== PRIVATE HELPERS ====================

  Future<String> _getToken() async {
    try {
      String? token = await _storage.read(key: 'jwt_token');
      return token ?? '';
    } catch (e) {
      debugPrint("Error reading token: $e");
      return '';
    }
  }

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _getToken();
    return {
      if (!isMultipart) 'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      // Sangat krusial untuk melihat detail Error 1265 dari MySQL di console
      debugPrint("HTTP Error Body: ${response.body}");
      throw HttpException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        uri: response.request?.url,
      );
    }
  }

  // ==================== AUTH & PROFILE ====================

  Future<Map<String, dynamic>?> fetchMyProfile() async {
    try {
      final response = await http.get(Uri.parse(authUrl), headers: await _getHeaders());
      final data = _handleResponse(response);

      if (data['status'] == 'success' && data['data'] != null) {
        return data['data']; // Berisi id_tingkat, id_wilayah, dll untuk auto-fill Satker
      }
      return null;
    } catch (e) {
      debugPrint("Error Fetch Profile: $e");
      return null;
    }
  }

  // ==================== CRUD OPERATIONS ====================

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
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (search.isNotEmpty) 'search': search,
        if (status.isNotEmpty) 'status': status,
        if (polres != null && polres.isNotEmpty) 'polres': polres,
        if (polsek != null && polsek.isNotEmpty) 'polsek': polsek,
        if (jenisLahan != null && jenisLahan.isNotEmpty) 'jenis_lahan': jenisLahan,
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _getHeaders());
      final data = _handleResponse(response);
      
      if (data['status'] == 'success' && data['data'] != null) {
        return (data['data'] as List)
            .map((x) => LandPotentialModel.fromJson(x))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error Fetch Data: $e");
      return [];
    }
  }

  Future<Map<String, List<String>>> fetchFilterOptions({String? polres}) async {
    try {
      final queryParams = <String, String>{
        if (polres != null && polres.isNotEmpty) 'polres': polres,
      };

      final uri = Uri.parse('$baseUrl/filter-options')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final response = await http.get(uri, headers: await _getHeaders());
      final data = _handleResponse(response);

      if (data['status'] == 'success' && data['data'] != null) {
        final responseData = data['data'];
        return {
          "polres": List<String>.from(responseData['polres'] ?? []),
          "polsek": List<String>.from(responseData['polsek'] ?? []),
          "jenis_lahan": List<String>.from(responseData['jenis_lahan'] ?? []),
          "komoditas": List<String>.from(responseData['komoditas'] ?? []),
        };
      }
      return _emptyFilterOptions();
    } catch (e) {
      debugPrint("Error Filter Options: $e");
      return _emptyFilterOptions();
    }
  }

  Map<String, List<String>> _emptyFilterOptions() => {
        "polres": [],
        "polsek": [],
        "jenis_lahan": [],
        "komoditas": [],
      };

  Future<bool> postLandData(LandPotentialModel data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
        body: json.encode(data.toJson()), // Mengirim "status_pakai" & "status_aktif" baru
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Post Land Data: $e");
      return false;
    }
  }

  Future<bool> updateLandData(String id, LandPotentialModel data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: await _getHeaders(),
        body: json.encode(data.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Update Land Data: $e");
      return false;
    }
  }

  Future<bool> deleteLandData(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Delete Land Data: $e");
      return false;
    }
  }

  // ==================== SUMMARY & ANALYTICS ====================

  Future<LandSummaryModel?> fetchSummaryData() async {
    try {
      final headers = await _getHeaders();
      // Optimalisasi: Jalankan request secara paralel
      final results = await Future.wait([
        http.get(Uri.parse("$baseUrl/summary"), headers: headers),
        http.get(Uri.parse("$baseUrl/no-potential"), headers: headers),
      ], eagerError: false);

      final summaryRes = results[0];
      final noPotentialRes = results[1];

      if (summaryRes.statusCode == 200) {
        final summaryData = json.decode(summaryRes.body);
        if (summaryData['status'] == 'success') {
          Map<String, dynamic> combinedData = Map<String, dynamic>.from(summaryData['data']);

          if (noPotentialRes.statusCode == 200) {
            try {
              final noPotentialData = json.decode(noPotentialRes.body);
              if (noPotentialData['status'] == 'success' && noPotentialData['data'] != null) {
                combinedData['details'] = noPotentialData['data']['details'];
              }
            } catch (e) {
              debugPrint("Error parsing no-potential data: $e");
            }
          }
          return LandSummaryModel.fromJson(combinedData);
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error Fetch Summary Data: $e");
      return null;
    }
  }

  Future<NoLandPotentialModel?> fetchNoLandData() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/no-potential"), headers: await _getHeaders());
      final data = _handleResponse(response);
      
      if (data['status'] == 'success' && data['data'] != null) {
        return NoLandPotentialModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint("Error Fetch No Land Data: $e");
      return null;
    }
  }

  // ==================== IMAGE HANDLING ====================

  Future<String> uploadImage(File imageFile, {String? customFilename}) async {
    try {
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final filename = customFilename ?? 'land_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload-image'));
      final token = await _getToken();
      if (token.isNotEmpty) request.headers['Authorization'] = 'Bearer $token';

      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        imageFile.path,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          return data['data']['url'] ?? data['data']['image_url'] ?? data['url'] ?? '';
        } else {
          throw Exception(data['message'] ?? 'Upload failed');
        }
      } else {
        throw HttpException('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error Upload Image: $e");
      throw Exception('Gagal mengupload gambar: $e');
    }
  }

  Future<Uint8List?> fetchImageBytes(String imageUrl) async {
    try {
      // FIX: Paksa fetch via endpoint /image/ untuk trigger decoder Base64 di Go
      final fullUrl = imageUrl.startsWith('http') ? imageUrl : '$baseUrl/image/$imageUrl';
      final response = await http.get(Uri.parse(fullUrl), headers: await _getHeaders());
      if (response.statusCode == 200) return response.bodyBytes;
      return null;
    } catch (e) {
      debugPrint("Error Fetch Image Bytes: $e");
      return null;
    }
  }

  Future<bool> deleteImage(String imageUrl) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete-image'),
        headers: await _getHeaders(),
        body: json.encode({'url': imageUrl}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Delete Image: $e");
      return false;
    }
  }

  // ==================== BATCH OPERATIONS ====================

  Future<bool> bulkDelete(List<String> ids) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bulk-delete'),
        headers: await _getHeaders(),
        body: json.encode({'ids': ids}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Bulk Delete: $e");
      return false;
    }
  }

  Future<bool> bulkUpdateStatus(List<String> ids, String newStatus) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bulk-update-status'),
        headers: await _getHeaders(),
        body: json.encode({
          'ids': ids,
          'status': newStatus,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Bulk Update Status: $e");
      return false;
    }
  }
}