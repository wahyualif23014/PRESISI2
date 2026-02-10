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
      _token = data['token'];
      _user = UserModel.fromJson(data['user']);

      await _storage.write(key: 'jwt_token', value: _token);
      await _storage.write(key: 'user_data', value: jsonEncode(_user!.toJson()));

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
      return null;
    } else {
      return result['message'];
    }
  }

  Future<void> tryAutoLogin() async {
    final savedToken = await _storage.read(key: 'jwt_token');

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
    final userString = await _storage.read(key: 'user_data');
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
    await _storage.deleteAll();
    notifyListeners();
  }
}