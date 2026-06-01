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

  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final mergedHeaders = await _getHeaders(customHeaders: headers);
    final response = await http.get(url, headers: mergedHeaders).timeout(const Duration(seconds: 15));
    if (response.statusCode == 401) {
      _handleUnauthorized();
      throw Exception('Token tidak valid atau sudah kadaluarsa.');
    }
    return response;
  }

  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final mergedHeaders = await _getHeaders(customHeaders: headers);
    final response = await http.post(url, headers: mergedHeaders, body: body, encoding: encoding).timeout(const Duration(seconds: 15));
    if (response.statusCode == 401) {
      _handleUnauthorized();
      throw Exception('Token tidak valid atau sudah kadaluarsa.');
    }
    return response;
  }

  static Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final mergedHeaders = await _getHeaders(customHeaders: headers);
    final response = await http.put(url, headers: mergedHeaders, body: body, encoding: encoding).timeout(const Duration(seconds: 15));
    if (response.statusCode == 401) {
      _handleUnauthorized();
      throw Exception('Token tidak valid atau sudah kadaluarsa.');
    }
    return response;
  }

  static Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final mergedHeaders = await _getHeaders(customHeaders: headers);
    final response = await http.delete(url, headers: mergedHeaders, body: body, encoding: encoding).timeout(const Duration(seconds: 15));
    if (response.statusCode == 401) {
      _handleUnauthorized();
      throw Exception('Token tidak valid atau sudah kadaluarsa.');
    }
    return response;
  }
}
