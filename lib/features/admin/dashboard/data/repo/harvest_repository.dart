import 'package:flutter/material.dart';
import '../model/harvest_model.dart';

class HarvestRepository {
  
  HarvestModel getHarvestData() {
    return HarvestModel(
      totalPanenCurrent: 12500, // Contoh data dari header widget lama
      unit: "Ton",
      categories: [
        // 1. DATA TOTAL HASIL
        HarvestCategoryData(
          id: 'total',
          label: 'Total Hasil',
          color: const Color(0xFF10B981), // Emerald
          isVisible: true, // Default true sesuai widget lama
          dataPoints: [
            const HarvestDataPoint(0, 3), const HarvestDataPoint(1, 4), 
            const HarvestDataPoint(2, 3.5), const HarvestDataPoint(3, 5),
            const HarvestDataPoint(4, 4.5), const HarvestDataPoint(5, 6),
            const HarvestDataPoint(6, 5.5), const HarvestDataPoint(7, 6.5),
            const HarvestDataPoint(8, 7), const HarvestDataPoint(9, 6),
            const HarvestDataPoint(10, 5), const HarvestDataPoint(11, 5.5),
          ],
        ),
        
        // 2. DATA JAGUNG
        HarvestCategoryData(
          id: 'jagung',
          label: 'Jagung',
          color: const Color(0xFFF59E0B), // Amber
          isVisible: false,
          dataPoints: [
            const HarvestDataPoint(0, 1), const HarvestDataPoint(1, 1.5),
            const HarvestDataPoint(2, 1.2), const HarvestDataPoint(3, 2),
            const HarvestDataPoint(4, 1.8), const HarvestDataPoint(5, 2.5),
            const HarvestDataPoint(6, 2), const HarvestDataPoint(7, 2.2),
            const HarvestDataPoint(8, 2.5), const HarvestDataPoint(9, 2),
            const HarvestDataPoint(10, 1.5), const HarvestDataPoint(11, 1.8),
          ],
        ),

        // 3. DATA UBI UNGU
        HarvestCategoryData(
          id: 'ubi',
          label: 'Ubi Ungu',
          color: const Color(0xFF8B5CF6), // Violet
          isVisible: false,
          dataPoints: [
            const HarvestDataPoint(0, 0.5), const HarvestDataPoint(1, 0.8),
            const HarvestDataPoint(2, 0.6), const HarvestDataPoint(3, 1),
            const HarvestDataPoint(4, 0.8), const HarvestDataPoint(5, 1.2),
            const HarvestDataPoint(6, 1), const HarvestDataPoint(7, 1.5),
            const HarvestDataPoint(8, 1.2), const HarvestDataPoint(9, 1),
            const HarvestDataPoint(10, 0.8), const HarvestDataPoint(11, 0.5),
          ],
        ),
      ],
    );
  }
}