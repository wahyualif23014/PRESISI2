class LandSummaryModel {
  final double totalArea;     // Contoh: 21313.03
  final int totalLocations;   // Contoh: 1350
  final List<LandSummaryItem> details; // List baris data (Milik Polri, Pesantren, dll)

  LandSummaryModel({
    required this.totalArea,
    required this.totalLocations,
    required this.details,
  });

  // Factory untuk convert dari JSON (Persiapan API)
  factory LandSummaryModel.fromJson(Map<String, dynamic> json) {
    var list = json['details'] as List;
    List<LandSummaryItem> detailsList = list.map((i) => LandSummaryItem.fromJson(i)).toList();

    return LandSummaryModel(
      totalArea: (json['total_area'] as num).toDouble(),
      totalLocations: json['total_locations'] as int,
      details: detailsList,
    );
  }
}

class LandSummaryItem {
  final String title;       // Contoh: "Milik Polri"
  final double area;        // Contoh: 6.59
  final int locationCount;  // Contoh: 5

  LandSummaryItem({
    required this.title,
    required this.area,
    required this.locationCount,
  });

  factory LandSummaryItem.fromJson(Map<String, dynamic> json) {
    return LandSummaryItem(
      title: json['title'] ?? '',
      area: (json['area'] as num).toDouble(),
      locationCount: json['location_count'] ?? 0,
    );
  }
}