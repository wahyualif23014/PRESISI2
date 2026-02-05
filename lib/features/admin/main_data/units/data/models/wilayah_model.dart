class WilayahModel {
  final int id;
  final String kabupaten;
  final String kecamatan;
  final double latitude;
  final double longitude;

  WilayahModel({
    required this.id,
    required this.kabupaten,
    required this.kecamatan,
    required this.latitude,
    required this.longitude,
  });

  factory WilayahModel.fromJson(Map<String, dynamic> json) {
    return WilayahModel(
      id: json['id_wilayah'] ?? 0,
      kabupaten: json['kabupaten'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_wilayah': id,
      'kabupaten': kabupaten,
      'kecamatan': kecamatan,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}