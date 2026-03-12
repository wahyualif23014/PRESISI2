import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = 'http://192.168.100.195:8080';
  
  // Instance Storage (Brankas Token)
  final _storage = const FlutterSecureStorage();

  // =========================
  // LOGIN
  // =========================
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      Map<String, dynamic> data = {};
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }

      if (response.statusCode == 200) {
        // Backend kadang pakai 'token' atau 'access_token'
        final token = data['token'] ?? data['access_token'];

        if (token == null) {
          return {
            'success': false,
            'message': 'Token tidak ditemukan dari server',
          };
        }

        await _storage.write(key: 'jwt_token', value: token);

        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message':
              data['error'] ??
              data['message'] ??
              'Login gagal (${response.statusCode})',
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'Server tidak bisa dijangkau'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  // =========================
  // REGISTER
  // =========================
  Future<Map<String, dynamic>> register({
    required String namaLengkap,
    required String idTugas,
    required String username,
    required int idJabatan,
    required String password,
    required String noTelp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama_lengkap': namaLengkap,
          'id_tugas': idTugas,
          'username': username,
          'id_jabatan': idJabatan,
          'password': password,
          'no_telp': noTelp,
        }),
      );

      Map<String, dynamic> data = {};
      if (response.body.isNotEmpty) {
        data = jsonDecode(response.body);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
        };
      } else {
        return {
          'success': false,
          'message':
              data['error'] ??
              data['message'] ??
              'Registrasi gagal (${response.statusCode})',
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'Server tidak bisa dijangkau'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // =========================
  // CEK TOKEN (BUAT VALIDASI)
  // =========================
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // =========================
  // CEK APAKAH SUDAH LOGIN
  // =========================
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }
}
