class LahanDetail {
  final String label;
  final double value;

  LahanDetail({required this.label, required this.value});

  factory LahanDetail.fromJson(Map<String, dynamic> json) => LahanDetail(
    label: json['label'] ?? '', 
    value: (json['value'] as num?)?.toDouble() ?? 0.0
  );
}

class LahanGroup {
  final double total;
  final List<LahanDetail> details;

  LahanGroup({required this.total, required this.details});

  factory LahanGroup.fromJson(Map<String, dynamic> json) {
    var list = json['details'] as List? ?? [];
    return LahanGroup(
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      details: list.map((i) => LahanDetail.fromJson(i)).toList(),
    );
  }

  // Helper untuk membuat dummy data dengan cepat
  factory LahanGroup.createDummy(double total, Map<String, double> items) {
    return LahanGroup(
      total: total,
      details: items.entries.map((e) => LahanDetail(label: e.key, value: e.value)).toList(),
    );
  }
}