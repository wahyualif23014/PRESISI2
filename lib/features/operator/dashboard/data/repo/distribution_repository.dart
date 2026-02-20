import 'package:flutter/material.dart';
import '../model/distribution_model.dart'; // Sesuaikan path

class DistributionRepository {
  
  // Data Dummy 1: Total Titik Lahan (Biru & Ungu)
  DistributionModel getTotalTitikLahan() {
    return DistributionModel(
      label: "Total Titik Lahan",
      total: 90,
      items: const [
        DistributionItem(value: 0.5, color: Color(0xFF3B82F6)), // Biru
        DistributionItem(value: 0.5, color: Color(0xFFC084FC)), // Ungu
      ],
    );
  }

  // Data Dummy 2: Pengelolah Lahan Polsek (Merah & Hijau)
  DistributionModel getPengelolaLahan() {
    return DistributionModel(
      label: "Pengelolah Lahan Polsek",
      total: 203,
      items: const [
        // Breakdown: 15% Mitra (Merah), 85% Polri (Hijau)
        DistributionItem(value: 0.15, color: Color(0xFFEF4444)), // Merah
        DistributionItem(value: 0.85, color: Color(0xFF22C55E)), // Hijau
      ],
    );
  }
}