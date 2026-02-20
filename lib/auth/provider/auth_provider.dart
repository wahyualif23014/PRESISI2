import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Import Master Model dan Enum Role
import '../models/auth_model.dart';
import '../models/role_enum.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  // --- GETTERS ---
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;

  // Pengecekan autentikasi via validitas Token
  bool get isAuthenticated {
    if (_token == null) return false;
    try {
      return !JwtDecoder.isExpired(_token!);
    } catch (e) {
      return false;
    }
  }

  // --- IAM ROLE GETTERS (Untuk kemudahan UI) ---
  UserRole get userRole => _user?.role ?? UserRole.unknown;
  bool get isAdmin => userRole == UserRole.admin;
  bool get isOperator => userRole == UserRole.operator;
  bool get isViewer => userRole == UserRole.view;

  // --- LOGIN LOGIC ---
  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(username, password);

      if (result['success']) {
        final data = result['data'];

        // Ambil token dan data user dari response backend
        _token = data['token'];
        _user = UserModel.fromJson(data['data'] ?? data['user']);

        // Simpan ke penyimpanan lokal (SharedPreferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        await prefs.setString('user_data', jsonEncode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return null; // Sukses
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

  // --- AUTO LOGIN (Restore Session) ---
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('jwt_token')) return;

    final savedToken = prefs.getString('jwt_token');
    if (savedToken == null) return;

    // Cek apakah token sudah expired
    if (JwtDecoder.isExpired(savedToken)) {
      await logout();
      return;
    }

    _token = savedToken;

    final userString = prefs.getString('user_data');
    if (userString != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(userString));
      } catch (e) {
        await logout();
        return;
      }
    }

    notifyListeners();
  }

  // --- REGISTER (Didaftarkan oleh Admin) ---
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

    if (result['success']) {
      return null; // Registrasi sukses
    } else {
      return result['message'];
    }
  }

  // --- LOGOUT LOGIC ---
  Future<void> logout() async {
    _token = null;
    _user = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    
    notifyListeners();
  }
}