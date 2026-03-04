import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/auth_model.dart';
import '../models/role_enum.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;

  bool get isAuthenticated {
    if (_token == null) return false;
    try {
      return !JwtDecoder.isExpired(_token!);
    } catch (e) {
      return false;
    }
  }

  UserRole get userRole => _user?.role ?? UserRole.unknown;
  bool get isAdmin => userRole == UserRole.admin;
  bool get isOperator => userRole == UserRole.operator;
  bool get isViewer => userRole == UserRole.view;

  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(username, password);

      if (result['success']) {
        final data = result['data'];

        _token = data['token'];

        // Ambil data user dari response
        final userData = data['data'] ?? data['user'];

        _user = UserModel.fromJson(userData);

        // Simpan ke SecureStorage
        await _storage.write(key: 'jwt_token', value: _token);
        await _storage.write(
          key: 'user_data',
          value: jsonEncode(_user!.toJson()),
        );
        await _storage.write(
          key: 'username',
          value: _user!.username,
        ); // FIX DI SINI

        _isLoading = false;
        notifyListeners();
        return null;
      } else {
        _isLoading = false;
        notifyListeners();
        return result['message'] ?? 'Login gagal, periksa kredensial Anda.';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Terjadi kesalahan sistem: $e";
    }
  }

  Future<void> tryAutoLogin() async {
    try {
      final savedToken = await _storage.read(key: 'jwt_token');
      if (savedToken == null) return;

      if (JwtDecoder.isExpired(savedToken)) {
        await logout();
        return;
      }

      _token = savedToken;

      final userString = await _storage.read(key: 'user_data');
      if (userString != null) {
        _user = UserModel.fromJson(jsonDecode(userString));
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Auto Login Error: $e");
    }
  }

  Future<String?> register({
    required String namaLengkap,
    required String idTugas,
    required String username,
    required int idJabatan,
    required String password,
    required String noTelp,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      namaLengkap: namaLengkap,
      idTugas: idTugas,
      username: username,
      idJabatan: idJabatan,
      password: password,
      noTelp: noTelp,
    );

    _isLoading = false;
    notifyListeners();
    return result['success'] ? null : result['message'];
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}
