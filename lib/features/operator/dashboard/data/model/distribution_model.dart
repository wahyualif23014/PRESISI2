import 'package:flutter/material.dart';

class DistributionItem {
  final double value; // Nilai persentase (0.0 - 1.0) atau nilai absolut
  final Color color;  // Warna chart untuk item ini

  const DistributionItem({
    required this.value,
    required this.color,
  });

  // Factory JSON (jika nanti ada warna dari API berupa Hex String)
  /*
  factory DistributionItem.fromJson(Map<String, dynamic> json) {
    return DistributionItem(
      value: (json['value'] as num).toDouble(),
      color: _parseColor(json['color_hex']), // Implementasi parse hex nanti
    );
  }
  */
}

class DistributionModel {
  final String label; // Judul Kartu (misal: "Total Titik Lahan")
  final int total;    // Angka Besar (misal: 90)
  final List<DistributionItem> items; // Data chart

  const DistributionModel({
    required this.label,
    required this.total,
    required this.items,
  });

  // --- HELPER GETTERS (Agar mudah dipakai di Widget) ---
  
  // Mengambil list proporsi saja (untuk chart)
  List<double> get proportions => items.map((e) => e.value).toList();

  // Mengambil list warna saja (untuk chart)
  List<Color> get colors => items.map((e) => e.color).toList();

  // --- FACTORY JSON ---
  factory DistributionModel.fromJson(Map<String, dynamic> json) {
    // Logic parsing JSON jika backend sudah siap
    // Sementara return object default agar tidak crash
    return DistributionModel(
      label: json['label'] ?? "-",
      total: (json['total'] as num?)?.toInt() ?? 0,
      items: [], // Nanti diisi logic parsing list items
    );
  }
}