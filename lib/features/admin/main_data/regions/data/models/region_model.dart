class WilayahModel {
  final String id;
  final String kabupaten;
  final String kecamatan;
  final String namaDesa;
  final double latitude;
  final double longitude;
  final String updatedBy;
  final String lastUpdated;

  WilayahModel({
    required this.id,
    required this.kabupaten,
    required this.kecamatan,
    required this.namaDesa,
    required this.latitude,
    required this.longitude,
    required this.updatedBy,
    required this.lastUpdated,
  });

  // Factory untuk parsing JSON dari Backend Go
  factory WilayahModel.fromJson(Map<String, dynamic> json) {
    return WilayahModel(
      id: json['id'] ?? '',
      kabupaten: json['kabupaten'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      namaDesa: json['namaDesa'] ?? '',
      // Handle konversi angka aman (jika backend kirim int/float/string)
      latitude:
          (json['latitude'] is num)
              ? (json['latitude'] as num).toDouble()
              : double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude:
          (json['longitude'] is num)
              ? (json['longitude'] as num).toDouble()
              : double.tryParse(json['longitude'].toString()) ?? 0.0,
      updatedBy: json['updatedBy'] ?? '-',
      lastUpdated: json['lastUpdated'] ?? '-',
    );
  }
}
