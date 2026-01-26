// Lokasi: lib/features/admin/main_data/jabatan/data/models/jabatan_model.dart

class JabatanModel {
  final String id;
  final String namaJabatan;
  final String? namaPejabat;   // Nullable jika jabatan kosong
  final String? nrp;           // Tambahan: Nomor Registrasi Pokok
  final String? tanggalPeresmian; // Tambahan: Format YYYY-MM-DD
  bool isSelected;             // Untuk logic checkbox UI

  JabatanModel({
    required this.id,
    required this.namaJabatan,
    this.namaPejabat,
    this.nrp,
    this.tanggalPeresmian,
    this.isSelected = false,
  });

  // Factory method (Untuk parsing JSON dari Backend nanti)
  factory JabatanModel.fromJson(Map<String, dynamic> json) {
    return JabatanModel(
      id: json['id'].toString(),
      namaJabatan: json['nama_jabatan'] ?? '',
      namaPejabat: json['nama_pejabat'], // Bisa null
      nrp: json['nrp'],                 // Bisa null
      tanggalPeresmian: json['tanggal_peresmian'], // Bisa null
      isSelected: false,
    );
  }

  // Method toMap (Untuk mengirim data KE Backend nanti)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_jabatan': namaJabatan,
      'nama_pejabat': namaPejabat,
      'nrp': nrp,
      'tanggal_peresmian': tanggalPeresmian,
    };
  }
}