enum SummaryType { success, failed, plant, process, potensi, lokasi }

class SummaryItemModel {
  final String label;
  final double value;
  final String unit;
  final SummaryType type;
  final double? percentage; // Tambahan untuk % validasi

  const SummaryItemModel({
    required this.label,
    required this.value,
    required this.unit,
    required this.type,
    this.percentage,
  });

  factory SummaryItemModel.fromJson(Map<String, dynamic> json) {
    return SummaryItemModel(
      label: json['label'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      percentage: (json['percentage'] as num?)?.toDouble(),
      type: _parseType(json['type']),
    );
  }

  static SummaryType _parseType(String? type) {
    switch (type) {
      case 'potensi': return SummaryType.potensi;
      case 'lokasi': return SummaryType.lokasi;
      case 'success': return SummaryType.success;
      default: return SummaryType.process;
    }
  }
}