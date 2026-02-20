import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/region_model.dart';

class RegionService {
  static const String _baseUrl = 'http://10.16.9.254:8080/api/admin/wilayah';

  Future<List<WilayahModel>> fetchRegions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('jwt_token');

      final response = await http.put(
        Uri.parse('$_baseUrl/$kode'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({"latitude": lat, "longitude": lng}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}