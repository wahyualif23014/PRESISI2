import 'role_enum.dart';
import 'unit_model.dart';

class Personel {
  final String id;
  final String namaLengkap;
  final String nrp;
  final String nomorHp;
  final String pangkat;
  final String jabatan;
  final UserRole role;
  final UnitKerja unitKerja;

  const Personel({
    required this.id,
    required this.namaLengkap,
    required this.nrp,
    required this.nomorHp,
    required this.pangkat,
    required this.jabatan,
    required this.role,
    required this.unitKerja,
  });

  // ============================
  // JSON MAPPING (UNTUK API)
  // ============================
  factory Personel.fromJson(Map<String, dynamic> json) {
    return Personel(
      id: json['id'],
      namaLengkap: json['nama_lengkap'],
      nrp: json['nrp'],
      nomorHp: json['nomor_hp'],
      pangkat: json['pangkat'],
      jabatan: json['jabatan'],
      role: UserRoleX.fromString(json['role']),
      unitKerja: UnitKerja.fromJson(json['unit_kerja']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'nrp': nrp,
      'nomor_hp': nomorHp,
      'pangkat': pangkat,
      'jabatan': jabatan,
      'role': role.label,
      'unit_kerja': unitKerja.toJson(),
    };
  }
}