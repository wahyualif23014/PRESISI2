import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/land_summary_model.dart';

class LandSummaryRepository {
  // SESUAIKAN IP
  final String baseUrl = "http://10.16.7.4:8080/api/potensi-lahan/summary";

  Future<LandSummaryModel?> getSummaryData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['status'] == 'success') {
          return LandSummaryModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      print("Error Summary Repo: $e");
      return null;
    }
  }
}
