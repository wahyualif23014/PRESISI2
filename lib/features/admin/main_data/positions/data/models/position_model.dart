// Lokasi: lib/features/admin/main_data/jabatan/data/jabatan_model.dart

class JabatanModel {
  final String id;
  final String namaJabatan;
  final String? namaPejabat;   // Bisa null jika jabatan kosong
  final String? lastUpdated;   // Bisa null
  bool isSelected;             // Untuk logic checkbox UI

  JabatanModel({
    required this.id,
    required this.namaJabatan,
    this.namaPejabat,
    this.lastUpdated,
    this.isSelected = false,
  });

  // Factory method (Persiapan jika nanti connect API)
  factory JabatanModel.fromJson(Map<String, dynamic> json) {
    return JabatanModel(
      id: json['id'] as String,
      namaJabatan: json['nama_jabatan'] as String,
      namaPejabat: json['nama_pejabat'] as String?,
      lastUpdated: json['updated_at'] as String?,
      isSelected: false,
    );
  }
}