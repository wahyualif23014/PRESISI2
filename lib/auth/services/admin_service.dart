import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Wajib ada untuk ambil token

class AdminService {
  final String baseUrl = 'http://10.16.2.233:8080'; 

  // Fungsi untuk mengambil Data Users (Admin Only)
  Future<List<dynamic>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token'); 

    // Cek apakah token ada
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan Login ulang.');
    }


    final response = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // <--- KUNCI UTAMA (Jangan lupa spasi setelah Bearer)
      },
    );

    // 3. CEK RESPON
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data']; // Mengembalikan list user
    } else if (response.statusCode == 401) {
      throw Exception('Sesi habis (401). Silakan Logout dan Login lagi.');
    } else {
      throw Exception('Gagal ambil data: ${response.statusCode}');
    }
  }
}