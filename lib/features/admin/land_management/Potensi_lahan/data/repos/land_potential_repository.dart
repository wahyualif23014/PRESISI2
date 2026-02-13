import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/land_potential_model.dart';

class LandPotentialRepository {
  // GANTI IP INI SESUAI KOMPUTERMU (cmd -> ipconfig)
  final String baseUrl = "http://192.168.1.10:8080/api/potensi-lahan";

  Future<List<LandPotentialModel>> getLandPotentials({
    String search = '',
    String status = '',
  }) async {
    try {
      String url = "$baseUrl?search=$search";
      if (status.isNotEmpty) {
        url += "&status=$status";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          List<dynamic> data = responseData['data'];
          return data.map((json) => LandPotentialModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      // Jika error / offline, kembalikan list kosong agar UI tidak crash
      return [];
    }
  }

  Future<bool> addLandPotential(LandPotentialModel data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
