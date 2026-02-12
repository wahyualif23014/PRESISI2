import 'package:flutter/material.dart';

class CommodityBanner extends StatelessWidget {
  final int totalCategories; // Jumlah Jenis (dari Card)
  final int totalItems; // Jumlah Tanaman (dari Database)

  const CommodityBanner({
    super.key,
    required this.totalCategories,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Gradient Hijau Segar
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. SATU ICON BESAR (PEMERSATU)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_rounded, // Icon Daun/Pertanian
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(width: 20), // Jarak Icon ke Teks
          // 2. INFO DATA (STATISTIK)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Statistik Data",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Baris A: Total Jenis
                Row(
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$totalCategories Jenis Komoditas",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Baris B: Total Tanaman (Nama Komoditi)
                Row(
                  children: [
                    const Icon(
                      Icons.local_florist_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$totalItems Tanaman Terdaftar",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
