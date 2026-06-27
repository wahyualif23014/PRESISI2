import 'dart:convert';
import 'package:KETAHANANPANGAN/core/config/api_config.dart';
import 'package:KETAHANANPANGAN/core/api/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/region_model.dart';

class RegionService {
  final String _baseUrl = "${ApiConfig.apiBaseUrl}/admin/wilayah";
  final _storage = const FlutterSecureStorage();

  Future<List<WilayahModel>> fetchRegions() async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');

      final response = await ApiClient.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => WilayahModel.fromJson(json)).toList();
      } else {
        if (response.statusCode == 404) return [];
        throw Exception('Gagal load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  Future<bool> updateCoordinate(String kode, double lat, double lng) async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');

      final response = await ApiClient.put(
        Uri.parse('$_baseUrl/$kode'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: json.encode({"latitude": lat, "longitude": lng}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
