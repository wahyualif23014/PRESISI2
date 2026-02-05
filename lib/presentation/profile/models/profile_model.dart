class ProfileModel {
  final int id;
  final String namaLengkap;
  final String nrp;
  final String jabatan; // Pengganti 'position'
  final String role;    
  final String noTelp;  // Tambahan dari Backend
  final String fotoProfil; 

  ProfileModel({
    required this.id,
    required this.namaLengkap,
    required this.nrp,
    required this.jabatan,
    required this.role,
    required this.noTelp,
    this.fotoProfil = '', 
  });

  // Factory method untuk membaca JSON dari Golang Backend
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0, 
      namaLengkap: json['nama_lengkap'] ?? '',  
      nrp: json['nrp'] ?? '',                   
      jabatan: json['jabatan'] ?? '',          
      role: json['role'] ?? 'view',            
      noTelp: json['no_telp'] ?? '-',          
      fotoProfil: json['foto_profil'] ?? '',   
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'nrp': nrp,
      'jabatan': jabatan,
      'role': role,
      'no_telp': noTelp,
      'foto_profil': fotoProfil,
    };
  }
}