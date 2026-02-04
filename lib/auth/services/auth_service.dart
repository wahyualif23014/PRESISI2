import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://10.16.2.163:8080'; 

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(String nrp, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nrp': nrp,
          'password': password,
        }),
      );

      // Decode response body
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data, // Berisi token & user object
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Terjadi kesalahan login',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server ($e)'};
    }
  }

  // --- REGISTER ---
  Future<Map<String, dynamic>> register({
    required String nama,
    required String nrp,
    required String jabatan,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama_lengkap': nama, // Key JSON harus sama dengan struct Go
          'nrp': nrp,
          'jabatan': jabatan,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false, 
          'message': data['error'] ?? 'Gagal mendaftar'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server ($e)'};
    }
  }
}