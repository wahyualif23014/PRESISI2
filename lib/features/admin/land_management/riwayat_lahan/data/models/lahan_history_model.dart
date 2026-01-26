// MODEL 1: Untuk Statistik Header (Kotak-kotak atas)
class LandHistorySummaryModel {
  final double totalPotensiLahan; 
  final double totalTanamLahan;   
  final double totalPanenLahanHa; 
  final double totalPanenLahanTon;
  final double totalSerapanTon;   

  LandHistorySummaryModel({
    required this.totalPotensiLahan,
    required this.totalTanamLahan,
    required this.totalPanenLahanHa,
    required this.totalPanenLahanTon,
    required this.totalSerapanTon,
  });

  factory LandHistorySummaryModel.fromJson(Map<String, dynamic> json) {
    return LandHistorySummaryModel(
      totalPotensiLahan: (json['total_potensi'] as num).toDouble(),
      totalTanamLahan: (json['total_tanam'] as num).toDouble(),
      totalPanenLahanHa: (json['total_panen_ha'] as num).toDouble(),
      totalPanenLahanTon: (json['total_panen_ton'] as num).toDouble(),
      totalSerapanTon: (json['total_serapan'] as num).toDouble(),
    );
  }
}

// MODEL 2: Untuk Item List Riwayat (Baris Data)
class LandHistoryItemModel {
  final String id;
  // Grouping Level 1 (Ungu Tua)
  final String regionGroup; 
  // Grouping Level 2 (Ungu Muda)
  final String subRegionGroup; 
  
  // Data Personil
  final String policeName;
  final String policePhone;
  final String picName; // Penanggung Jawab
  final String picPhone;
  
  // Data Lahan
  final double landArea; // Luas (HA)
  final String landCategory; // Tambahan khusus Riwayat: "POKTAN BINAAN POLRI"
  
  // Status
  final String status;   // Contoh: "PROSES PANEN"
  final String statusColor; 

  LandHistoryItemModel({
    required this.id,
    required this.regionGroup,
    required this.subRegionGroup,
    required this.policeName,
    required this.policePhone,
    required this.picName,
    required this.picPhone,
    required this.landArea,
    required this.landCategory, // Field baru
    required this.status,
    this.statusColor = '#FF9800', 
  });

  factory LandHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return LandHistoryItemModel(
      id: json['id'] ?? '',
      regionGroup: json['region_group'] ?? '',
      subRegionGroup: json['sub_region_group'] ?? '',
      policeName: json['police_name'] ?? '',
      policePhone: json['police_phone'] ?? '',
      picName: json['pic_name'] ?? '',
      picPhone: json['pic_phone'] ?? '',
      landArea: (json['land_area'] as num).toDouble(),
      landCategory: json['land_category'] ?? '', // Mapping field baru
      status: json['status'] ?? 'PROSES PANEN',
      statusColor: json['status_color'] ?? '#FF9800',
    );
  }
}