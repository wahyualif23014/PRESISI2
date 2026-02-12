import 'package:flutter/material.dart';

class CommodityCategoryModel {
  final String id;
  final String title;
  final String imageAsset;
  final List<String> tags;

  const CommodityCategoryModel({
    required this.id,
    required this.title,
    required this.imageAsset,
    required this.tags,
  });

  factory CommodityCategoryModel.fromJson(Map<String, dynamic> json) {
    return CommodityCategoryModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      imageAsset: json['imageAsset'] ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  IconData getCategoryIcon() {
    final t = title.toUpperCase();
    if (t.contains('HORTIKULTURA')) return Icons.local_florist;
    if (t.contains('PERKEBUNAN')) return Icons.agriculture;
    if (t.contains('PANGAN')) return Icons.grass;
    if (t.contains('BUAH')) return Icons.apple;
    return Icons.category;
  }
}
