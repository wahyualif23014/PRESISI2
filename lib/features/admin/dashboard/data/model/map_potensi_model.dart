class MapPotensiModel {
  final int totalPoints;
  final List<MapPotensiItem> points;

  MapPotensiModel({
    required this.totalPoints,
    required this.points,
  });

  factory MapPotensiModel.fromJson(Map<String, dynamic> json) {
    return MapPotensiModel(
      totalPoints: (json['total_points'] ?? 0) is int
          ? (json['total_points'] ?? 0)
          : int.tryParse(json['total_points'].toString()) ?? 0,
      points: (json['points'] as List? ?? [])
          .whereType<Map>()
          .map((e) => MapPotensiItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class MapPotensiItem {
  final String idLahan;
  final double lat;
  final double lng;
  final double luasLahan;
  final String statusLahan;
  final String jenisLahan;

  final String? idKomoditi;
  final String? namaKomoditi;
  final String? jenisKomoditi;

  final String? kodeWilayah;
  final String? namaWilayah;

  MapPotensiItem({
    required this.idLahan,
    required this.lat,
    required this.lng,
    required this.luasLahan,
    required this.statusLahan,
    required this.jenisLahan,
    this.idKomoditi,
    this.namaKomoditi,
    this.jenisKomoditi,
    this.kodeWilayah,
    this.namaWilayah,
  });

  factory MapPotensiItem.fromJson(Map<String, dynamic> json) {
    double _toD(dynamic v) => (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0;

    String? _toS(dynamic v) {
      final s = v?.toString();
      if (s == null) return null;
      final t = s.trim();
      return t.isEmpty ? null : t;
    }

    return MapPotensiItem(
      idLahan: (json['id_lahan'] ?? '').toString(),
      lat: _toD(json['lat']),
      lng: _toD(json['lng']),
      luasLahan: _toD(json['luas_lahan']),
      statusLahan: (json['status_lahan'] ?? '').toString(),
      jenisLahan: (json['jenis_lahan'] ?? '').toString(),
      idKomoditi: _toS(json['id_komoditi']),
      namaKomoditi: _toS(json['nama_komoditi']),
      jenisKomoditi: _toS(json['jenis_komoditi']),
      kodeWilayah: _toS(json['kode_wilayah']),
      namaWilayah: _toS(json['nama_wilayah']),
    );
  }
}