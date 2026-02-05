class UserModel {
  final int id;
  final String namaLengkap;
  final String nrp;
  final String jabatan;
  final String role;
  final String? fotoProfil;
  
  // TAMBAHAN: Field Nomor Telepon
  final String? noTelp; 

  UserModel({
    required this.id,
    required this.namaLengkap,
    required this.nrp,
    required this.jabatan,
    required this.role,
    this.fotoProfil,
    this.noTelp, // Masukkan ke constructor
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['ID'] ?? json['id'] ?? 0,
      namaLengkap: json['nama_lengkap'] ?? '',
      nrp: json['nrp'] ?? '',
      jabatan: json['jabatan'] ?? '',
      role: json['role'] ?? 'view',
      fotoProfil: json['foto_profil'],
      
      // Mapping dari JSON backend (snake_case) ke variable Dart (camelCase)
      noTelp: json['no_telp'], 
    );
  }

  // Method untuk mengubah Object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'nama_lengkap': namaLengkap,
      'nrp': nrp,
      'jabatan': jabatan,
      'role': role,
      'foto_profil': fotoProfil,
      'no_telp': noTelp, // Simpan ke JSON
    };
  }
}