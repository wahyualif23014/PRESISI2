class UnitModel {
  final String kode;
  final String nama;

  UnitModel({required this.kode, required this.nama});

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      kode: json['kode'] ?? '',
      nama: json['nama'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'kode': kode, 'nama': nama};
}

class JabatanModel {
  final int id;
  final String namaJabatan;

  JabatanModel({required this.id, required this.namaJabatan});

  factory JabatanModel.fromJson(Map<String, dynamic> json) {
    return JabatanModel(
      id: json['id'] ?? 0,
      namaJabatan: json['nama_jabatan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nama_jabatan': namaJabatan};
}