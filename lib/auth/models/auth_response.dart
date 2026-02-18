import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';

class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      // Menangani jika data user berada di dalam key 'data' atau 'user'
      user: UserModel.fromJson(json['data'] ?? json['user'] ?? {}),
    );
  }
}