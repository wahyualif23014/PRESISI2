import 'role_enum.dart'; // Pastikan file ini ada dan enum-nya sesuai ('admin','view','polres','polsek')

class Personel {
  final int id; // Ubah ke int karena di Golang gorm.Model ID itu uint
  final String namaLengkap;
  final String nrp;
  final String jabatan;
  final String? noTelp; // Nullable (bisa kosong)
  final String? fotoProfil; // Nullable (bisa kosong)
  final UserRole role; // Menggunakan Enum

  const Personel({
    required this.id,
    required this.namaLengkap,
    required this.nrp,
    required this.jabatan,
    this.noTelp,
    this.fotoProfil,
    required this.role,
  });

  // ============================
  // JSON MAPPING (DARI API)
  // ============================
  factory Personel.fromJson(Map<String, dynamic> json) {
    return Personel(
      id: json['ID'] ?? json['id'] ?? 0,

      namaLengkap: json['nama_lengkap'] ?? '',
      nrp: json['nrp'] ?? '',
      jabatan: json['jabatan'] ?? '',

      noTelp: json['no_telp'],
      fotoProfil: json['foto_profil'],

      // Parsing Role
      role: UserRoleX.fromString(json['role'] ?? 'view'),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'nrp': nrp,
      'jabatan': jabatan,
      'no_telp': noTelp,
      'foto_profil': fotoProfil,
      'role':
          role.label, // Pastikan role.label mengembalikan string 'admin', 'polres', dll.
    };
  }
}
