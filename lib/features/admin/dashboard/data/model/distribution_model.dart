class WilayahDistributionModel {
  final String namaWilayah;
  final int totalTitik;
  final double totalLuasPotensi;
  final double totalLuasTanam;

  WilayahDistributionModel({
    required this.namaWilayah,
    required this.totalTitik,
    required this.totalLuasPotensi,
    required this.totalLuasTanam,
  });

  factory WilayahDistributionModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return WilayahDistributionModel(
      namaWilayah: (json['nama_wilayah'] ?? '').toString(),
      totalTitik: _toInt(json['total_titik']),
      totalLuasPotensi: _toDouble(json['total_luas_potensi']),
      totalLuasTanam: _toDouble(json['total_luas_tanam']),
    );
  }
}