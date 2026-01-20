class WilayahModel {
  final String id;
  final String kabupaten;   // Header Level 1 (misal: BANGKALAN)
  final String kecamatan;   // Header Level 2 (misal: AROSBAYA)
  final String namaDesa;    // Data Utama
  final double latitude;
  final double longitude;
  final String updatedBy;   // Info User (misal: KOMBES POL SIH HARNO...)
  final String lastUpdated; // Tanggal

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
}