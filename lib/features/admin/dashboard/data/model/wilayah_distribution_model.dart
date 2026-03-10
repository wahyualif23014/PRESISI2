class WilayahDistributionModel {
  final String label;
  final double value;

  WilayahDistributionModel({
    required this.label,
    required this.value,
  });

  factory WilayahDistributionModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return WilayahDistributionModel(
      label: (json['label'] ?? '').toString(),
      value: _toDouble(json['value']),
    );
  }
}