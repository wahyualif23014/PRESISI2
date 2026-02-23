class LandManagementSummaryModel {
  final double totalPotensiLahan;
  final double totalTanamLahan;
  final double totalPanenLahanHa;
  final double totalPanenLahanTon;
  final double totalSerapanTon;

  LandManagementSummaryModel({
    required this.totalPotensiLahan,
    required this.totalTanamLahan,
    required this.totalPanenLahanHa,
    required this.totalPanenLahanTon,
    required this.totalSerapanTon,
  });

  factory LandManagementSummaryModel.fromJson(Map<String, dynamic> json) {
    return LandManagementSummaryModel(
      totalPotensiLahan: (json['total_potensi'] as num?)?.toDouble() ?? 0.0,
      totalTanamLahan: (json['total_tanam'] as num?)?.toDouble() ?? 0.0,
      totalPanenLahanHa: (json['total_panen_ha'] as num?)?.toDouble() ?? 0.0,
      totalPanenLahanTon: (json['total_panen_ton'] as num?)?.toDouble() ?? 0.0,
      totalSerapanTon: (json['total_serapan'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LandManagementItemModel {
  final String id;
  final String regionGroup;
  final String subRegionGroup;
  final String policeName;
  final String policePhone;
  final String picName;
  final String picPhone;
  final double landArea;

  final double luasTanam;
  final String estPanen;
  final double luasPanen;
  final double hasilPanen;
  final double serapan;

  final String status;
  final String statusColor;
  final String kategoriLahan;

  LandManagementItemModel({
    required this.id,
    required this.regionGroup,
    required this.subRegionGroup,
    required this.policeName,
    required this.policePhone,
    required this.picName,
    required this.picPhone,
    required this.landArea,
    required this.luasTanam,
    required this.estPanen,
    required this.luasPanen,
    required this.hasilPanen,
    required this.serapan,
    required this.status,
    required this.statusColor,
    this.kategoriLahan = '-',
  });

  factory LandManagementItemModel.fromJson(Map<String, dynamic> json) {
    return LandManagementItemModel(
      id: json['id']?.toString() ?? '',
      regionGroup: json['region_group'] ?? '-',
      subRegionGroup: json['sub_region_group'] ?? '-',
      policeName: json['police_name'] ?? '-',
      policePhone: json['police_phone'] ?? '-',
      picName: json['pic_name'] ?? '-',
      picPhone: json['pic_phone'] ?? '-',

      landArea: (json['land_area'] as num?)?.toDouble() ?? 0.0,

      luasTanam: (json['luas_tanam'] as num?)?.toDouble() ?? 0.0,
      estPanen: json['est_panen'] ?? '-',
      luasPanen: (json['luas_panen'] as num?)?.toDouble() ?? 0.0,
      hasilPanen: (json['berat_panen'] as num?)?.toDouble() ?? 0.0,
      serapan: (json['serapan'] as num?)?.toDouble() ?? 0.0,

      status: json['status'] ?? 'BELUM TANAM',
      statusColor: json['status_color'] ?? '#FF9800',
      kategoriLahan: json['kategori_lahan'] ?? '-',
    );
  }
}
