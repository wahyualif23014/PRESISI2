class NoLandPotentialModel {
  final int totalPolres; // Contoh: 17
  final List<NoLandDetailItem> details; // List rincian (Polsek, Kabupaten, dll)

  NoLandPotentialModel({
    required this.totalPolres,
    required this.details,
  });

  factory NoLandPotentialModel.fromJson(Map<String, dynamic> json) {
    var list = json['details'] as List;
    List<NoLandDetailItem> detailsList =
        list.map((i) => NoLandDetailItem.fromJson(i)).toList();

    return NoLandPotentialModel(
      totalPolres: json['total_polres'] ?? 0,
      details: detailsList,
    );
  }
}

class NoLandDetailItem {
  final String label; // Contoh: "Polsek", "Kabupaten / Kota"
  final int count;    // Contoh: 300

  NoLandDetailItem({
    required this.label,
    required this.count,
  });

  factory NoLandDetailItem.fromJson(Map<String, dynamic> json) {
    return NoLandDetailItem(
      label: json['label'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}