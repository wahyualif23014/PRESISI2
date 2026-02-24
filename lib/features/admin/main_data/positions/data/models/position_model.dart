class JabatanModel {
  final int id; // Sesuai dengan json:"id" di Go
  final String namaJabatan;
  final int? idAnggota;
  bool isSelected;

  JabatanModel({
    required this.id,
    required this.namaJabatan,
    this.isSelected = false,
    this.idAnggota,
  });

  factory JabatanModel.fromJson(Map<String, dynamic> json) {
    return JabatanModel(
      id: json['id'], // Mapping dari json:"id"
      namaJabatan: json['nama_jabatan'] ?? '', // Mapping dari json:"nama_jabatan"
      idAnggota: json['id_anggota'], // Mapping dari json:"id_anggota"
    );
  }
}