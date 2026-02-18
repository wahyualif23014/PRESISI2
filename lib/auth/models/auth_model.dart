import 'package:KETAHANANPANGAN/auth/models/role_enum.dart';
import 'package:KETAHANANPANGAN/auth/models/unit_model.dart';

class UserModel {
  final int id;
  final String namaLengkap;
  final String nrp;        // Identity: Username/NRP
  final String idTugas;    // Kode Satker (misal: 11)
  final UserRole role;     // Type-safe Enum
  final String? noTelp;
  final String? fotoProfil;

  // Detail Relasi dari Backend (GORM Preload)
  final JabatanModel? jabatanDetail;
  final UnitModel? tingkatDetail;

  UserModel({
    required this.id,
    required this.namaLengkap,
    required this.nrp,
    required this.idTugas,
    required this.role,
    this.noTelp,
    this.fotoProfil,
    this.jabatanDetail,
    this.tingkatDetail,
  });

  // --- GETTERS UNTUK KONSISTENSI UI ---
  
  // Solusi Error: Mengambil ID dari objek Jabatan
  int get idJabatan => jabatanDetail?.id ?? 0;

  // Solusi Error: Mengambil teks label role (Administrator, dsb)
  String get roleDisplay => role.label;

  // Alias untuk kompatibilitas logic auth lama
  String get username => nrp;

  bool get isAdmin => role == UserRole.admin;

  // --- SERIALIZATION (SINKRONISASI BACKEND) ---
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      // Handle fallback nama kolom database 'nama' vs 'nama_lengkap'
      namaLengkap: json['nama_lengkap'] ?? json['nama'] ?? '',
      nrp: json['nrp'] ?? json['username'] ?? '',
      idTugas: json['id_tugas'] ?? json['idtugas'] ?? '',
      
      // Sinkronisasi tipe data role '1','2','3' ke Enum
      role: UserRoleX.fromString(json['role']?.toString() ?? json['statusadmin']?.toString() ?? '3'),
      
      noTelp: json['no_telp'] ?? json['hp'],
      fotoProfil: json['foto_profil'],

      // PENTING: Kunci JSON 'jabatan' sesuai Tag di userModel.go
      jabatanDetail: json['jabatan'] != null 
          ? JabatanModel.fromJson(json['jabatan']) 
          : (json['jabatan_detail'] != null ? JabatanModel.fromJson(json['jabatan_detail']) : null),
      
      // Kunci JSON 'tingkat_detail' sesuai Tag di userModel.go
      tingkatDetail: json['tingkat_detail'] != null 
          ? UnitModel.fromJson(json['tingkat_detail']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'username': nrp,
      'id_tugas': idTugas,
      'role': role.value, // Konversi Enum ke String '1','2','3'
      'no_telp': noTelp,
      'id_jabatan': idJabatan,
    };
  }
}