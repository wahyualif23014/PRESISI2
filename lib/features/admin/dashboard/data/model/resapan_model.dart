class ResapanItem {
  final String label;
  final double value; // Gunakan double agar konsisten dengan HA

  ResapanItem({required this.label, required this.value});

  factory ResapanItem.fromJson(Map<String, dynamic> json) {
    return ResapanItem(
      label: json['label'] ?? "-",
      // Menggunakan num? agar bisa nerima int maupun double dari JSON
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ResapanModel {
  final String year;
  final double total; // Pastikan double
  final List<ResapanItem> items;

  ResapanModel({required this.year, required this.total, required this.items});

  factory ResapanModel.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    return ResapanModel(
      year: json['year']?.toString() ?? "2026",
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      items: list.map((i) => ResapanItem.fromJson(i)).toList(),
    );
  }
}