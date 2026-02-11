// Lokasi: lib/features/admin/main_data/jabatan/data/models/jabatan_model.dart

class JabatanModel {
  final String id;
  final String namaJabatan;
  final String? namaPejabat;
  final String? nrp;
  final String? tanggalPeresmian;

  final String? idAnggota;

  // State UI
  bool isSelected;

  JabatanModel({
    required this.id,
    required this.namaJabatan,
    this.namaPejabat,
    this.nrp,
    this.tanggalPeresmian,
    this.idAnggota,
    this.isSelected = false,
  });

  factory JabatanModel.fromJson(Map<String, dynamic> json) {
    return JabatanModel(
      id: json['id']?.toString() ?? '0',

      namaJabatan: json['nama_jabatan'] ?? '',

      // Sesuai DTO Backend Go (JabatanResponse)
      namaPejabat: json['nama_pejabat'] ?? '-',
      nrp: json['nrp'] ?? '-',

      tanggalPeresmian: json['tanggal_peresmian'],

      idAnggota: json['id_anggota']?.toString(),

      isSelected: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.tryParse(id) ?? 0,
      'nama_jabatan': namaJabatan,
      'id_anggota': idAnggota != null ? int.tryParse(idAnggota!) : null,
    };
  }
}
