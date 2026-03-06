import 'package:flutter/material.dart';

class HarvestDataPoint {
  final int monthIndex; // Normalized to 0-11
  final int? year;
  final double value;

  const HarvestDataPoint({
    required this.monthIndex,
    this.year,
    required this.value,
  });

  factory HarvestDataPoint.fromJson(Map<String, dynamic> json) {
    // Optimalisasi 1: Normalisasi index dari SQL (1-12) ke Chart (0-11)
    final int rawMonth = (json['month_index'] as num?)?.toInt() ?? 1;
    
    return HarvestDataPoint(
      monthIndex: rawMonth > 0 ? rawMonth - 1 : 0, 
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
    // Optimalisasi 2: Parsing & Sorting data points secara internal
    final List<HarvestDataPoint> points = (json['data_points'] as List? ?? [])
        .map((x) => HarvestDataPoint.fromJson(x))
        .toList();

    // Sorting krusial untuk kestabilan LineChart fl_chart
    points.sort((a, b) => a.monthIndex.compareTo(b.monthIndex));

    return HarvestCategoryData(
      id: json['id']?.toString() ?? '',
      label: json['label'] ?? '',
      color: _parseColor(json['color']),
      isVisible: json['is_visible'] ?? true,
      dataPoints: points,
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.green;
    try {
      String hexColor = hex.replaceAll('#', '');
      if (hexColor.length == 6) hexColor = 'FF$hexColor';
      return Color(int.parse('0x$hexColor'));
    } catch (e) {
      return Colors.green;
    }
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
      unit: json['unit'] ?? 'HA',
      categories: (json['categories'] as List? ?? [])
          .map((x) => HarvestCategoryData.fromJson(x))
          .toList(),
    );
  }
}