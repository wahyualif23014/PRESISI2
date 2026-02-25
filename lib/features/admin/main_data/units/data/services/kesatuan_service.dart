import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Pakai ini, bukan SharedPreferences
import 'package:shared_preferences/shared_preferences.dart'; // Buat jaga-jaga
import '../models/kesatuan_model.dart';

class KesatuanService {
  final String baseUrl = "http://192.168.100.196:8080/api/admin/tingkat";
  Future<List<KesatuanModel>> getKesatuan() async {
    String? token;

    const storage = FlutterSecureStorage();
    token = await storage.read(key: 'jwt_token'); // Coba nama key 'jwt_token'

    if (token == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token'); // Coba nama key 'token'

      // Coba nama key lain yang mungkin dipakai
      if (token == null) {
        token = prefs.getString('jwt_token');
      }
    }

    // 3. JIKA MASIH KOSONG JUGA -> LEMPAR ERROR
    if (token == null) {
      print(
        "DEBUG: Token benar-benar kosong di Storage maupun SharedPreferences",
      );
      throw Exception('Token tidak ditemukan. Silakan Logout dan Login ulang.');
    }

    // 4. REQUEST KE BACKEND
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        return data.map((item) => KesatuanModel.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesi habis (Unauthorized). Silakan Login ulang.');
      } else {
        throw Exception(
          'Gagal memuat data: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }
}
