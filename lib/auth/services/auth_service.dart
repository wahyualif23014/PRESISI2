import 'dart:convert';
import 'dart:io'; // Import untuk SocketException
import 'package:http/http.dart' as http;

class AuthService {
  // Pastikan IP ini sesuai dengan IP Laptop Anda
  final String baseUrl = 'http://10.16.15.29:8080';

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
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Periksa koneksi internet atau IP server.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // --- REGISTER ---
  Future<Map<String, dynamic>> register({
    required String nama,
    required String nrp,
    required String jabatan,
    required String password,
    required String role,
    required String noTelp, // Tambahan parameter No Telp
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama_lengkap': nama,
          'nrp': nrp,
          'jabatan': jabatan,
          'password': password,
          'role': role,
          'no_telp': noTelp, // Kirim ke Backend (sesuai JSON tag di Go)
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Gagal mendaftar',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server. Periksa koneksi internet atau IP server.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}