class SummaryItem {
  final String label; // Contoh: "Berhasil"
  final double value; // Contoh: 90
  final String unit;  // Contoh: "HA"
  final String type;  

  SummaryItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.type,
  });

  factory SummaryItem.fromJson(Map<String, dynamic> json) {
    return SummaryItem(
      label: json['label'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'HA',
      type: json['type'] ?? 'process',
    );
  }
}