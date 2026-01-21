class QuarterlyItem {
  final double value;
  final String unit;
  final String label;   // Contoh: "Tanam Lahan Produktif"
  final String period;  // Contoh: "Kwartal 1"

  QuarterlyItem({
    required this.value,
    required this.unit,
    required this.label,
    required this.period,
  });

  factory QuarterlyItem.fromJson(Map<String, dynamic> json) {
    return QuarterlyItem(
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'HA',
      label: json['label'] ?? '',
      period: json['period'] ?? '',
    );
  }
}