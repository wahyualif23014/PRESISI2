import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pakai ini saja biar sinkron
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;

  bool get isAuthenticated {
    if (_token == null) return false;
    return !JwtDecoder.isExpired(_token!);
  }

  Future<String?> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(username, password);

    if (result['success']) {
      final data = result['data'];

      // 1. Ambil token dari Backend (biasanya key json-nya 'token')
      _token = data['token'];
      _user = UserModel.fromJson(data['user']);

      // 2. SIMPAN KE HP DENGAN NAMA 'jwt_token'
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', _token!); // <--- KUNCI DIRUBAH DISINI
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));

      _isLoading = false;
      notifyListeners();
      return null;
    } else {
      _isLoading = false;
      notifyListeners();
      return result['message'];
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
    // ... (Kode register sama seperti sebelumnya) ...
    return null;
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    // 3. CEK APAKAH ADA 'jwt_token'
    if (!prefs.containsKey('jwt_token')) return;

    final savedToken = prefs.getString('jwt_token'); // <--- BACA DISINI

    if (savedToken == null) {
      _token = null;
      _user = null;
      notifyListeners();
      return;
    }

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

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    notifyListeners();
  }
}
