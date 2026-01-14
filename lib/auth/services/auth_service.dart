import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/models/auth_model.dart'; // Pastikan import path ini sesuai dengan file AuthModel Anda

class AuthService {
  // Instance Supabase Client
  final SupabaseClient _supabase = Supabase.instance.client;

  // ------------------------------------------------------------------------
  // 1. SIGN IN (LOGIN)
  // ------------------------------------------------------------------------
  Future<AuthModel> login(String email, String password) async {
    try {
      print("Mencoba login ke Supabase: $email");

      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final Session? session = res.session;
      final User? user = res.user;

      if (session != null && user != null) {

        return _mapUserToAuthModel(user, session.accessToken);
      } else {
        throw 'Login gagal: Sesi tidak ditemukan.';
      }
    } on AuthException catch (e) {
      print("Supabase Auth Error: ${e.message}");
      throw e.message; 
    } catch (e) {
      print("General Error: $e");
      throw 'Terjadi kesalahan sistem.';
    }
  }

  // 2. SIGN UP (REGISTER - PENTING UNTUK 4 USER ANDA)

  Future<void> signUp({
    required String email,
    required String password,
    required String nama,
    required String role,
    required String satuanKerja,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'nama': nama,
          'role': role,
          'satuan_kerja': satuanKerja,
        },
      );
      print("User $email berhasil didaftarkan dengan role $role");
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Gagal mendaftar: $e';
    }
  }

  // ------------------------------------------------------------------------
  // 3. GET CURRENT USER (CEK SESSION SAAT APLIKASI DIBUKA)
  // ------------------------------------------------------------------------
  AuthModel? getCurrentUser() {
    final session = _supabase.auth.currentSession;
    final user = _supabase.auth.currentUser;

    if (session != null && user != null) {
      // Cek apakah token expired (opsional, supabase handle auto refresh biasanya)
      if (session.isExpired) return null;
      
      return _mapUserToAuthModel(user, session.accessToken);
    }
    return null;
  }

  // ------------------------------------------------------------------------
  // 4. SIGN OUT (LOGOUT)
  // ------------------------------------------------------------------------
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ------------------------------------------------------------------------
  // HELPER: MAPPING DATA SUPABASE -> AUTH MODEL
  // ------------------------------------------------------------------------
  AuthModel _mapUserToAuthModel(User user, String token) {
    // Mengambil data dari user_metadata
    final metadata = user.userMetadata ?? {};

    return AuthModel.fromJson(
      {
        'nama': metadata['nama'],
        'role': metadata['role'],
        'satuan_kerja': metadata['satuan_kerja'],
      },
      token,
    );
  }
}