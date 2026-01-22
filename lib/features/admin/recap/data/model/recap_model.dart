class RecapModel {
  final String id;
  final String namaWilayah;
  final double potensiLahan; // Dalam HA
  final double tanamLahan;   // Dalam HA
  final double panenLuas;    // Dalam HA
  final double panenTon;     // Dalam TON
  final double serapan;      // Dalam HA
  final bool isHeader;       // True jika ini adalah 'POLRES' (Ungu), False jika 'POLSEK'

  RecapModel({
    required this.id,
    required this.namaWilayah,
    required this.potensiLahan,
    required this.tanamLahan,
    required this.panenLuas,
    required this.panenTon,
    required this.serapan,
    this.isHeader = false,
  });

  // --- FACTORY JSON (Untuk integrasi API nanti) ---
  factory RecapModel.fromJson(Map<String, dynamic> json) {
    return RecapModel(
      id: json['id'] ?? '',
      namaWilayah: json['nama_wilayah'] ?? '',
      potensiLahan: (json['potensi_lahan'] as num?)?.toDouble() ?? 0.0,
      tanamLahan: (json['tanam_lahan'] as num?)?.toDouble() ?? 0.0,
      panenLuas: (json['panen_luas'] as num?)?.toDouble() ?? 0.0,
      panenTon: (json['panen_ton'] as num?)?.toDouble() ?? 0.0,
      serapan: (json['serapan'] as num?)?.toDouble() ?? 0.0,
      isHeader: json['is_header'] ?? false,
    );
  }

  // Helper untuk tampilan UI "0 HA / 0 TON"
  String get panenDisplay => "${panenLuas.toStringAsFixed(0)} HA / ${panenTon.toStringAsFixed(0)} TON";
}