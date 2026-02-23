class LandSummaryCategory {
  final String title;
  final double area;
  final int count;

  LandSummaryCategory({
    required this.title,
    required this.area,
    required this.count,
  });

  factory LandSummaryCategory.fromJson(Map<String, dynamic> json) {
    return LandSummaryCategory(
      title: json['title'] ?? "-",
      area: (json['area'] ?? 0).toDouble(),
      count: (json['count'] ?? 0).toInt(),
    );
  }
}

class AdminCounts {
  final int polres;
  final int polsek;
  final int kabKota;
  final int kecamatan;
  final int kelDesa;

  AdminCounts({
    required this.polres,
    required this.polsek,
    required this.kabKota,
    required this.kecamatan,
    required this.kelDesa,
  });

  factory AdminCounts.fromJson(Map<String, dynamic> json) {
    return AdminCounts(
      polres: (json['kab_kota'] ?? 0).toInt(),
      polsek: (json['polsek'] ?? 0).toInt(),
      kabKota: (json['kab_kota'] ?? 0).toInt(),
      kecamatan: (json['kecamatan'] ?? 0).toInt(),
      kelDesa: (json['kel_desa'] ?? 0).toInt(),
    );
  }
}

class LandSummaryModel {
  final double totalArea;
  final int totalLocations;
  final List<LandSummaryCategory> categories;
  final AdminCounts adminCounts;

  LandSummaryModel({
    required this.totalArea,
    required this.totalLocations,
    required this.categories,
    required this.adminCounts,
  });

  factory LandSummaryModel.fromJson(Map<String, dynamic> json) {
    var list = json['categories'] as List? ?? [];
    List<LandSummaryCategory> catList =
        list.map((i) => LandSummaryCategory.fromJson(i)).toList();

    return LandSummaryModel(
      totalArea: (json['total_area'] ?? 0).toDouble(),
      totalLocations: (json['total_locations'] ?? 0).toInt(),
      categories: catList,
      // Mengambil data dari key 'details' yang dikirim oleh backend Go
      adminCounts: AdminCounts.fromJson(json['details'] ?? {}),
    );
  }
}
