class UserModel {
  final int id;
  final String namaLengkap;
  final String nrp;
  final String jabatan;
  final String role;
  final String status;
  final String? fotoProfil;

  UserModel({
    required this.id,
    required this.namaLengkap,
    required this.nrp,
    required this.jabatan,
    required this.role,
    required this.status,
    this.fotoProfil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['ID'] ?? 0, // Go GORM default ID huruf besar, tapi cek response Anda
      namaLengkap: json['nama_lengkap'] ?? '',
      nrp: json['nrp'] ?? '',
      jabatan: json['jabatan'] ?? '',
      role: json['role'] ?? 'view',
      status: json['status'] ?? 'pending',
      fotoProfil: json['foto_profil'],
    );
  }

  // Method untuk mengubah Object -> JSON (jika perlu disimpan ke storage)
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'nama_lengkap': namaLengkap,
      'nrp': nrp,
      'jabatan': jabatan,
      'role': role,
      'status': status,
      'foto_profil': fotoProfil,
    };
  }
}