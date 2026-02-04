import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  // --- LOGIN LOGIC ---
  Future<String?> login(String nrp, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(nrp, password);

    if (result['success']) {
      final data = result['data'];
      _token = data['token'];
      
      // Convert JSON user ke Object UserModel
      _user = UserModel.fromJson(data['user']);

      // Simpan Token & User Data ke HP (Persistent)
      await _storage.write(key: 'jwt_token', value: _token);
      await _storage.write(key: 'user_data', value: jsonEncode(_user!.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return null; // Null artinya sukses tanpa error message
    } else {
      _isLoading = false;
      notifyListeners();
      return result['message']; // Return pesan error
    }
  }

  // --- REGISTER LOGIC ---
  Future<String?> register({
    required String nama,
    required String nrp,
    required String jabatan,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      nama: nama,
      nrp: nrp,
      jabatan: jabatan,
      password: password,
      role: role,
    );

    _isLoading = false;
    notifyListeners();

    if (result['success']) {
      return null; // Sukses
    } else {
      return result['message']; // Return error
    }
  }

  // --- AUTO LOGIN (Saat App Dibuka) ---
  Future<void> tryAutoLogin() async {
    final savedToken = await _storage.read(key: 'jwt_token');
    
    if (savedToken == null) return;

    // Cek Expired Token
    if (JwtDecoder.isExpired(savedToken)) {
      await logout();
      return;
    }

    _token = savedToken;
    
    // Load User Data
    final userString = await _storage.read(key: 'user_data');
    if (userString != null) {
      _user = UserModel.fromJson(jsonDecode(userString));
    }

    notifyListeners();
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}