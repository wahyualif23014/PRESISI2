import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/no_land_potential_model.dart';

class NoLandPotentialRepository {
  // GANTI IP SESUAI SERVER
  final String baseUrl =
      "http://10.16.7.4:8080/api/potensi-lahan/no-potential";

  Future<NoLandPotentialModel?> getNoLandData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          return NoLandPotentialModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      print("Error Repo NoLand: $e");
      return null;
    }
  }
}
