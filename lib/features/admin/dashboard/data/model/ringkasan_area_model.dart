import 'package:flutter/material.dart';

enum LandCategory {
  productive,   // Produktif -> Icon Gear
  forestry,     // Perhutanan -> Icon Pohon
  agriculture,  
  religious,    
  other,        
}

class RingkasanAreaItemModel {
  final LandCategory category;
  final String label;
  final double value;

  const RingkasanAreaItemModel({
    required this.category,
    required this.label,
    required this.value,
  });
}

class RingkasanAreaModel {
  final String title;            // Judul bawah (Ex: "Total Potensi Lahan...")
  final double totalValue;       // Angka besar di kanan atas (Ex: 430.98)
  final Color backgroundColor;   // Warna kartu (Biru/Hijau/Merah)
  final bool isDetailed;         // Logika UI: True = List Panjang, False = Grid Compact
  final List<RingkasanAreaItemModel> items; // Daftar item data kecil-kecil

  const RingkasanAreaModel({
    required this.title,
    required this.totalValue,
    required this.backgroundColor,
    required this.items,
    this.isDetailed = false,
  });
}