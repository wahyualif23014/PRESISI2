import 'package:flutter/material.dart';

class HarvestDataPoint {
  final int monthIndex;
  final int? year;
  final double value;

  const HarvestDataPoint({
    required this.monthIndex,
    this.year,
    required this.value,
  });

  factory HarvestDataPoint.fromJson(Map<String, dynamic> json) {
    return HarvestDataPoint(
      monthIndex: json['month_index'] ?? 0,
      year: json['year'],
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class HarvestCategoryData {
  final String id;
  final String label;
  final Color color;
  final List<HarvestDataPoint> dataPoints;
  bool isVisible;

  HarvestCategoryData({
    required this.id,
    required this.label,
    required this.color,
    required this.dataPoints,
    this.isVisible = true,
  });

  factory HarvestCategoryData.fromJson(Map<String, dynamic> json) {
    return HarvestCategoryData(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      color: _parseColor(json['color']),
      dataPoints: (json['data_points'] as List? ?? [])
          .map((x) => HarvestDataPoint.fromJson(x))
          .toList(),
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.green;
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

class HarvestModel {
  final double totalPanenCurrent;
  final String unit;
  final List<HarvestCategoryData> categories;

  HarvestModel({
    required this.totalPanenCurrent,
    required this.unit,
    required this.categories,
  });

  factory HarvestModel.fromJson(Map<String, dynamic> json) {
    return HarvestModel(
      totalPanenCurrent: (json['total_panen_current'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      categories: (json['categories'] as List? ?? [])
          .map((x) => HarvestCategoryData.fromJson(x))
          .toList(),
    );
  }
}