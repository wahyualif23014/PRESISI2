import 'package:flutter/material.dart';

class RingkasanAreaItemModel {
  final String label;
  final double value; // HA
  final int count;    // LOKASI (Tambahan)

  const RingkasanAreaItemModel({
    required this.label,
    required this.value,
    required this.count,
  });

  factory RingkasanAreaItemModel.fromJson(Map<String, dynamic> json) {
    return RingkasanAreaItemModel(
      label: json['label'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class RingkasanAreaModel {
  final String title;
  final double totalValue;
  final Color backgroundColor;
  final List<RingkasanAreaItemModel> items;

  const RingkasanAreaModel({
    required this.title,
    required this.totalValue,
    required this.backgroundColor,
    required this.items,
  });

  factory RingkasanAreaModel.fromJson(Map<String, dynamic> json) {
    return RingkasanAreaModel(
      title: json['title'] ?? '',
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      backgroundColor: _parseColor(json['background_color']),
      items: (json['items'] as List? ?? [])
          .map((e) => RingkasanAreaItemModel.fromJson(e))
          .toList(),
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null) return Colors.blue;
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}