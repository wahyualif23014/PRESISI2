import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/core/globals.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';

class ApiClient {
  static const _storage = FlutterSecureStorage();
  
  static Future<Map<String, String>> _getHeaders({Map<String, String>? customHeaders}) async {
    final token = await _storage.read(key: 'jwt_token');
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    
    return headers;
  }
  
  static void _handleUnauthorized() {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      context.read<AuthProvider>().forceLogout('Sesi Anda telah berakhir. Silakan login kembali.');
    }
  }

  static void _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      _handleUnauthorized();
      throw Exception('Token tidak valid atau sudah kadaluarsa.');
    }

    // Cek isi body jika API return 200 tapi isinya pesan error session / id null
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        final message = body['message']?.toString().toLowerCase() ?? '';
        final error = body['error']?.toString().toLowerCase() ?? '';
        
        if (message.contains('id null') || 
            error.contains('id null') ||
            message.contains('token') && message.contains('expire') ||
            message.contains('unauthorized')) {
          _handleUnauthorized();
          throw Exception('Sesi tidak valid. Silakan login kembali.');
        }
      }
    } catch (_) {}
  }

  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final mergedHeaders = await _getHeaders(customHeaders: headers);
    final response = await http.get(url, headers: mergedHeaders).timeout(const Duration(seconds: 15));
    _checkUnauthorized(response);
    return response;
  }

  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final mergedHeaders = await _getHeaders(customHeaders: headers);
    final response = await http.post(url, headers: mergedHeaders, body: body, encoding: encoding).timeout(const Duration(seconds: 15));
    _checkUnauthorized(response);
    return response;
  }

  static Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final mergedHeaders = await _getHeaders(customHeaders: headers);
    final response = await http.put(url, headers: mergedHeaders, body: body, encoding: encoding).timeout(const Duration(seconds: 15));
    _checkUnauthorized(response);
    return response;
  }

  static Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final mergedHeaders = await _getHeaders(customHeaders: headers);
    final response = await http.delete(url, headers: mergedHeaders, body: body, encoding: encoding).timeout(const Duration(seconds: 15));
    _checkUnauthorized(response);
    return response;
  }
}
