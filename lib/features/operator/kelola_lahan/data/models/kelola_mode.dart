// MODEL 1: Untuk Statistik Header (Kotak-kotak atas)
class LandManagementSummaryModel {
  final double totalPotensiLahan; // 6,124.35
  final double totalTanamLahan;   // 620.45
  final double totalPanenLahanHa; // 3.20
  final double totalPanenLahanTon;// 16.00
  final double totalSerapanTon;   // 0.00

  LandManagementSummaryModel({
    required this.totalPotensiLahan,
    required this.totalTanamLahan,
    required this.totalPanenLahanHa,
    required this.totalPanenLahanTon,
    required this.totalSerapanTon,
  });

  // Persiapan untuk API (JSON Parsing)
  factory LandManagementSummaryModel.fromJson(Map<String, dynamic> json) {
    return LandManagementSummaryModel(
      totalPotensiLahan: (json['total_potensi'] as num).toDouble(),
      totalTanamLahan: (json['total_tanam'] as num).toDouble(),
      totalPanenLahanHa: (json['total_panen_ha'] as num).toDouble(),
      totalPanenLahanTon: (json['total_panen_ton'] as num).toDouble(),
      totalSerapanTon: (json['total_serapan'] as num).toDouble(),
    );
  }
}

// MODEL 2: Untuk Item List (Baris Data)
class LandManagementItemModel {
  final String id;
  final String regionGroup; 
  final String subRegionGroup; 
  
  // Data Kolom
  final String policeName;
  final String policePhone;
  final String picName; // Penanggung Jawab
  final String picPhone;
  final double landArea; // Luas (HA)
  final String status;   // Contoh: "PROSES PANEN", "PROSES TANAM"
  final String statusColor; // Hex color code dari API (opsional) atau enum

  LandManagementItemModel({
    required this.id,
    required this.regionGroup,
    required this.subRegionGroup,
    required this.policeName,
    required this.policePhone,
    required this.picName,
    required this.picPhone,
    required this.landArea,
    required this.status,
    this.statusColor = '#FF9800', // Default Orange
  });

  factory LandManagementItemModel.fromJson(Map<String, dynamic> json) {
    return LandManagementItemModel(
      id: json['id'] ?? '',
      regionGroup: json['region_group'] ?? '',
      subRegionGroup: json['sub_region_group'] ?? '',
      policeName: json['police_name'] ?? '',
      policePhone: json['police_phone'] ?? '',
      picName: json['pic_name'] ?? '',
      picPhone: json['pic_phone'] ?? '',
      landArea: (json['land_area'] as num).toDouble(),
      status: json['status'] ?? 'PROSES PANEN',
      statusColor: json['status_color'] ?? '#FF9800',
    );
  }
}