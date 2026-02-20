import 'package:flutter/material.dart';

class HarvestDataPoint {
  final int monthIndex; // 0 = JAN, 1 = FEB, dst.
  final double value;   // Nilai dalam Ribuan Ton (k)

  const HarvestDataPoint(this.monthIndex, this.value);
}

class HarvestCategoryData {
  final String id;
  final String label;
  final Color color;
  final List<HarvestDataPoint> dataPoints;
  bool isVisible; // Untuk state toggle di UI

  HarvestCategoryData({
    required this.id,
    required this.label,
    required this.color,
    required this.dataPoints,
    this.isVisible = false,
  });
}

class HarvestModel {
  final double totalPanenCurrent; // Total panen saat ini (Header)
  final String unit;              // Satuan (Ton)
  final List<HarvestCategoryData> categories; // List kategori (Total, Jagung, Ubi)

  HarvestModel({
    required this.totalPanenCurrent,
    required this.unit,
    required this.categories,
  });
}