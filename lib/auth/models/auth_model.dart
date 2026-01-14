class AuthModel {
  final String token;
  final String nama;
  final String role;        
  final String satuanKerja; // Contoh: "POLDA JATIM"

  AuthModel({
    required this.token,
    required this.nama,
    required this.role,
    required this.satuanKerja,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json, String token) {
    return AuthModel(
      token: token,
      nama: json['nama'] ?? 'Tanpa Nama',
      role: json['role'] ?? 'USER',
      satuanKerja: json['satuan_kerja'] ?? '-',
    );
  }

  @override
  String toString() {
    return 'AuthModel(nama: $nama, role: $role, satker: $satuanKerja)';
  }
}