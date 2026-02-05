import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  // Gunakan const constructor untuk performa
  final _storage = const FlutterSecureStorage();

  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  
  // Logic Authenticated: Token ada DAN tidak expired
  bool get isAuthenticated {
    if (_token == null) return false;
    // Optional: Tambahan safety check (meski biasanya sudah dicek saat load)
    return !JwtDecoder.isExpired(_token!);
  }

  // --- LOGIN LOGIC ---
  Future<String?> login(String nrp, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(nrp, password);

    if (result['success']) {
      final data = result['data'];
      _token = data['token'];
      
      // Convert JSON user ke Object UserModel (termasuk no_telp jika ada)
      _user = UserModel.fromJson(data['user']);

      // Simpan Token & User Data ke HP (Persistent)
      await _storage.write(key: 'jwt_token', value: _token);
      await _storage.write(key: 'user_data', value: jsonEncode(_user!.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return null; // Sukses (Null Error)
    } else {
      _isLoading = false;
      notifyListeners();
      return result['message']; // Return pesan error dari Backend
    }
  }

  // --- REGISTER LOGIC (UPDATE) ---
  Future<String?> register({
    required String nama,
    required String nrp,
    required String jabatan,
    required String password,
    required String role,
    required String noTelp, // Tambahan Parameter Wajib
  }) async {
    _isLoading = true;
    notifyListeners();

    // Meneruskan data (termasuk noTelp) ke AuthService
    final result = await _authService.register(
      nama: nama,
      nrp: nrp,
      jabatan: jabatan,
      password: password,
      role: role,
      noTelp: noTelp, 
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
    
    if (savedToken == null) {
      _token = null;
      _user = null;
      notifyListeners();
      return;
    }

    // Cek apakah token expired?
    if (JwtDecoder.isExpired(savedToken)) {
      // Jika expired, hapus semua data login
      await logout();
      return;
    }

    // Jika token Valid, load data
    _token = savedToken;
    final userString = await _storage.read(key: 'user_data');
    if (userString != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(userString));
      } catch (e) {
        // Jika data user corrupt, logout paksa
        await logout();
        return;
      }
    }

    notifyListeners();
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.deleteAll(); // Hapus semua data di Secure Storage
    notifyListeners();
  }
}