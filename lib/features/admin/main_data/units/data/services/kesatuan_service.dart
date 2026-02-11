import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Pakai ini, bukan SharedPreferences
import 'package:shared_preferences/shared_preferences.dart'; // Buat jaga-jaga
import '../models/kesatuan_model.dart';

class KesatuanService {
  // Ganti IP sesuai konfigurasi kamu (10.0.2.2 untuk Emulator, IP asli untuk HP fisik)
  final String baseUrl = "http://10.16.1.116:8080/view/tingkat";

  Future<List<KesatuanModel>> getKesatuan() async {
    String? token;

    // 1. COBA AMBIL DARI SECURE STORAGE (Biasanya Login pakai ini)
    const storage = FlutterSecureStorage();
    token = await storage.read(key: 'jwt_token'); // Coba nama key 'jwt_token'

    // 2. JIKA KOSONG, COBA DARI SHARED PREFERENCES (Backup)
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
