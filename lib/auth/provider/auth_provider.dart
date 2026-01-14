import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _service = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuth => _user != null;

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final AuthModel resultUser = await _service.login(email, password);
      _user = resultUser;

      await _storage.write(key: 'token', value: _user!.token);
      await _storage.write(key: 'nama', value: _user!.nama);
      await _storage.write(key: 'role', value: _user!.role);
      await _storage.write(key: 'satuan_kerja', value: _user!.satuanKerja);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Gunakan debugPrint untuk log di production code
      debugPrint("Error Login: $e");

      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- REGISTER ---
  Future<bool> register({
    required String email,
    required String password,
    required String nama,
    required String role,
    required String satuanKerja,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.signUp(
        email: email,
        password: password,
        nama: nama,
        role: role,
        satuanKerja: satuanKerja,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error Register: $e");
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- AUTO LOGIN ---
  Future<bool> tryAutoLogin() async {
    final AuthModel? existingUser = _service.getCurrentUser();

    if (existingUser != null) {
      _user = existingUser;
      await _storage.write(key: 'token', value: _user!.token);
      notifyListeners();
      return true;
    }

    return false;
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _service.signOut();
    await _storage.deleteAll();
    _user = null;
    notifyListeners();
  }
}
