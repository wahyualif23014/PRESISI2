class KesatuanModel {
  final String kode;
  final String namaSatuan;
  final String namaPejabat;
  final String jabatan;
  final String noHp;
  final String wilayah;
  final int totalPolsek;
  final List<KesatuanModel> daftarPolsek;

  KesatuanModel({
    required this.kode,
    required this.namaSatuan,
    required this.namaPejabat,
    required this.jabatan,
    required this.noHp,
    required this.wilayah,
    required this.totalPolsek,
    required this.daftarPolsek,
  });

  factory KesatuanModel.fromJson(Map<String, dynamic> json) {
    var list = json['daftar_polsek'] as List? ?? [];
    List<KesatuanModel> polsekList =
        list.map((i) => KesatuanModel.fromJson(i)).toList();

    return KesatuanModel(
      kode: json['kode_kesatuan'] ?? '-',
      namaSatuan: json['nama_satuan'] ?? '-',
      namaPejabat: json['nama_pejabat'] ?? '-',
      jabatan: json['jabatan_pejabat'] ?? '-',
      noHp: json['no_hp'] ?? '-',
      wilayah: json['wilayah'] ?? '-',
      totalPolsek: json['total_polsek'] ?? 0,
      daftarPolsek: polsekList,
    );
  }
}