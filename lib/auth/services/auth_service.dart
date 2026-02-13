import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://10.16.7.228:8080';

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Login failed',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection or server unreachable',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Registration failed',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection or server unreachable',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}