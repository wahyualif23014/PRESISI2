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
      // Menggunakan .toDouble() untuk menghindari error tipe data num
      area: (json['area'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
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
      polres: (json['polres'] ?? 0).toInt(),
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
    // Perbaikan: Ambil data dari 'categories' bukan 'details'
    var list = json['categories'] as List? ?? [];
    List<LandSummaryCategory> catList =
        list.map((i) => LandSummaryCategory.fromJson(i)).toList();

    return LandSummaryModel(
      totalArea: (json['total_area'] ?? 0).toDouble(),
      totalLocations: json['total_locations'] ?? 0,
      categories: catList,
      adminCounts: AdminCounts.fromJson(json['admin_counts'] ?? {}),
    );
  }
}
