class UserModel {
  final int id;
  final String namaLengkap;
  final String nrp;
  final String jabatan;
  final String role;
  // Field 'status' DIHAPUS karena di backend sudah tidak ada
  final String? fotoProfil;

  UserModel({
    required this.id,
    required this.namaLengkap,
    required this.nrp,
    required this.jabatan,
    required this.role,
    this.fotoProfil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['ID'] ?? json['id'] ?? 0, 
      namaLengkap: json['nama_lengkap'] ?? '',
      nrp: json['nrp'] ?? '',
      jabatan: json['jabatan'] ?? '',
      role: json['role'] ?? 'view', // Default role jika null
      fotoProfil: json['foto_profil'],
    );
  }

  // Method untuk mengubah Object -> JSON (jika perlu disimpan ke storage HP)
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'nama_lengkap': namaLengkap,
      'nrp': nrp,
      'jabatan': jabatan,
      'role': role,
      'foto_profil': fotoProfil,
    };
  }
}