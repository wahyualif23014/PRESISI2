import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/dashboard/data/model/ringkasan_area_model.dart';

class RingkasanAreaRepository {
  
  // Method untuk mengambil data (bisa dibuat tidak static jika ingin inject dependency nanti)
  List<RingkasanAreaModel> getRingkasanList() {
    
    // Data Item Default yang berulang
    final defaultItems = [
      const RingkasanAreaItemModel(
        category: LandCategory.productive,
        label: "Produktif",
        value: 192.23,
      ),
      const RingkasanAreaItemModel(
        category: LandCategory.forestry,
        label: "Perhutanan",
        value: 192.23,
      ),
      const RingkasanAreaItemModel(
        category: LandCategory.agriculture,
        label: "Luas Baku Sawah (LBS)",
        value: 192.23,
      ),
      const RingkasanAreaItemModel(
        category: LandCategory.religious,
        label: "Pesantren",
        value: 192.23,
      ),
    ];

    return [
      // 1. Kartu Biru (Detailed / Vertical List)
      RingkasanAreaModel(
        title: "Total Potensi Lahan\nSampai Tahun 2026",
        totalValue: 430.98,
        backgroundColor: const Color(0xFF1E427F), // Warna Biru Tua
        isDetailed: true, // Layout List ke bawah
        items: defaultItems,
      ),

      RingkasanAreaModel(
        title: "Total Lahan Tanam Tahun 2026",
        totalValue: 123.21,
        backgroundColor: const Color(0xFF107C41), // Warna Hijau
        isDetailed: false, // Layout Grid 2 kolom
        items: defaultItems,
      ),

      RingkasanAreaModel(
        title: "Total Lahan Panen Tahun 2026",
        totalValue: 234.98,
        backgroundColor: const Color(0xFFD32F2F), // Warna Merah
        isDetailed: false, // Layout Grid 2 kolom
        items: defaultItems,
      ),
    ];
  }
}