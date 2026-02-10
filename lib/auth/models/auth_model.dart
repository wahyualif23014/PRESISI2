import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/models/position_model.dart';

class UserModel {
  final int id;
  final String namaLengkap;
  final String idTugas;
  final String username;
  final int idJabatan;
  final String role;
  final String? noTelp;
  final String? fotoProfil;

  final JabatanModel? jabatanDetail;

  UserModel({
    required this.id,
    required this.namaLengkap,
    required this.idTugas,
    required this.username,
    required this.idJabatan,
    required this.role,
    this.noTelp,
    this.fotoProfil,
    this.jabatanDetail,
  });

  // --- LOGIC DISPLAY ROLE ---
  // Pastikan logic ini ada untuk menerjemahkan '1' jadi 'Administrator'
  String get roleDisplay {
    switch (role) {
      case '1':
        return 'Administrator';
      case '2':
        return 'Operator';
      case '3':
        return 'View Only';
      default:
        return 'Unknown Role';
    }
  }

  bool get isAdmin => role == '1';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      namaLengkap: json['nama_lengkap'] ?? '',
      idTugas: json['id_tugas'] ?? '',
      username: json['username'] ?? '',

      idJabatan:
          json['id_jabatan'] is int
              ? json['id_jabatan']
              : int.tryParse(json['id_jabatan'].toString()) ?? 0,

      role: json['role']?.toString() ?? '3',

      noTelp: json['no_telp'],
      fotoProfil: json['foto_profil'],

      jabatanDetail:
          json['jabatan_detail'] != null
              ? JabatanModel.fromJson(json['jabatan_detail'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'id_tugas': idTugas,
      'username': username,
      'id_jabatan': idJabatan,
      'role': role,
      'no_telp': noTelp,
      'foto_profil': fotoProfil,
      'jabatan_detail': jabatanDetail?.toJson(),
    };
  }
}
