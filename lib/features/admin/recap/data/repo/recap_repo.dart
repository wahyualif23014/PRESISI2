import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../model/recap_model.dart'; // Sesuaikan import

class RecapRepo {
  // Ganti IP sesuai konfigurasi jaringan
  final String baseUrl = "http://192.168.100.195:8080/api/rekapitulasi";

  Future<List<RecapModel>> getRecapData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data
            .map((json) => RecapModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception("Gagal mengambil data: HTTP ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Kesalahan Koneksi: $e");
    }
  }

  Future<String?> downloadExcel() async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 15);

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String fileName =
          "Rekap_Presisi_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      final String savePath = "${directory!.path}/$fileName";

      final response = await dio.download("$baseUrl/export", savePath);

      if (response.statusCode == 200) {
        return savePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
