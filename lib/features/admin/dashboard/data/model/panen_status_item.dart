class PanenStatusItem {
  final String label;
  final double value;
  final String unit;

  PanenStatusItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  factory PanenStatusItem.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    return PanenStatusItem(
      label: (json['label'] ?? '').toString(),
      value: toDouble(json['value']),
      unit: (json['unit'] ?? '').toString(),
    );
  }
}