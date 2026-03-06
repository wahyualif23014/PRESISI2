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

class LandHistoryItemModel {
  final String id;
  final String regionGroup;
  final String subRegionGroup;
  final String policeName;
  final String policePhone;
  final String picName;
  final String picPhone;
  final double landArea;
  final double tanamArea;
  final String estPanen;
  final double panenArea;
  final double panenTon;
  final double serapanTon;
  final String landCategory;
  final String status;
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
    required this.tanamArea,
    required this.estPanen,
    required this.panenArea,
    required this.panenTon,
    required this.serapanTon,
    required this.landCategory,
    required this.status,
    this.statusColor = '#FF9800',
  });

  factory LandHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return LandHistoryItemModel(
      id: json['id']?.toString() ?? '',
      regionGroup: json['region_group'] ?? '',
      subRegionGroup: json['sub_region_group'] ?? '',
      policeName: json['police_name'] ?? '',
      policePhone: json['police_phone'] ?? '',
      picName: json['pic_name'] ?? '',
      picPhone: json['pic_phone'] ?? '',
      landArea: (json['land_area'] as num?)?.toDouble() ?? 0.0,
      tanamArea: (json['tanam_ha'] as num?)?.toDouble() ?? 0.0,
      estPanen: json['est_panen'] ?? '-',
      panenArea: (json['panen_ha'] as num?)?.toDouble() ?? 0.0,
      panenTon: (json['panen_ton'] as num?)?.toDouble() ?? 0.0,
      serapanTon: (json['serapan_ton'] as num?)?.toDouble() ?? 0.0,
      landCategory: json['land_category'] ?? '-',
      status: json['status'] ?? '',
      statusColor: json['status_color'] ?? '#9E9E9E',
    );
  }
}
