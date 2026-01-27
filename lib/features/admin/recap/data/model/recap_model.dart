enum RecapRowType { polres, polsek, desa }

class RecapModel {
  final String id;
  final String namaWilayah;
  final double potensiLahan;
  final double tanamLahan;
  final double panenLuas;
  final double panenTon;
  final double serapan;
  final RecapRowType type;
  final String? namaPolsek;

  RecapModel({
    required this.id,
    required this.namaWilayah,
    required this.potensiLahan,
    required this.tanamLahan,
    required this.panenLuas,
    required this.panenTon,
    required this.serapan,
    this.type = RecapRowType.desa,
    this.namaPolsek,
  });

  factory RecapModel.fromJson(Map<String, dynamic> json) {
    RecapRowType parseType(dynamic val) {
      if (val == 'polres' || val == 0) return RecapRowType.polres;
      if (val == 'polsek' || val == 1) return RecapRowType.polsek;
      return RecapRowType.desa;
    }

    return RecapModel(
      id: json['id'] ?? '',
      namaWilayah: json['nama_wilayah'] ?? '',
      potensiLahan: (json['potensi_lahan'] as num?)?.toDouble() ?? 0.0,
      tanamLahan: (json['tanam_lahan'] as num?)?.toDouble() ?? 0.0,
      panenLuas: (json['panen_luas'] as num?)?.toDouble() ?? 0.0,
      panenTon: (json['panen_ton'] as num?)?.toDouble() ?? 0.0,
      serapan: (json['serapan'] as num?)?.toDouble() ?? 0.0,
      type: parseType(json['level']),
      namaPolsek: json['nama_polsek'], 
    );
  }

  RecapModel copyWith({String? namaPolsek}) {
    return RecapModel(
      id: id,
      namaWilayah: namaWilayah,
      potensiLahan: potensiLahan,
      tanamLahan: tanamLahan,
      panenLuas: panenLuas,
      panenTon: panenTon,
      serapan: serapan,
      type: type,
      namaPolsek: namaPolsek ?? this.namaPolsek,
    );
  }

  String get panenDisplay => "${panenLuas.toStringAsFixed(0)} HA / ${panenTon.toStringAsFixed(0)} TON";
}