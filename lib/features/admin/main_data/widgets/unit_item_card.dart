// Lokasi: lib/features/admin/main_data/units/widgets/unit_item_card.dart

import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/main_data/units/data/unit_model.dart';

class UnitItemCard extends StatelessWidget {
  final UnitModel unit;

  const UnitItemCard({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final String initial =
        unit.title.isNotEmpty ? unit.title[0].toUpperCase() : "?";

    return Container(
      margin: EdgeInsets.only(left: unit.isPolres ? 0 : 20, bottom: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      decoration: BoxDecoration(
        color: unit.isPolres ? Colors.white : const Color(0xFFF8F9FC), // Background Cool Grey tipis
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1), // Garis pemisah lebih halus
          left: unit.isPolres
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFD1D5DB), width: 3), // Garis indikator abu-abu modern
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42, // Ukuran sedikit diperbesar
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unit.isPolres
                  ? const Color(0xFF1E3A8A) 
                  : const Color(0xFFEFF6FF), // Blue 50
              shape: BoxShape.circle,
              border: Border.all(
                color: unit.isPolres 
                    ? Colors.transparent 
                    : const Color(0xFFBFDBFE), // Blue 200 border untuk Polsek
                width: 1.5,
              ),
              boxShadow: unit.isPolres 
                ? [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] 
                : null,
            ),
            child: Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: unit.isPolres ? Colors.white : const Color(0xFF1E3A8A),
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // --- 2. KONTEN TEKS ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  unit.title, // Tidak perlu uppercase semua agar lebih humanis (opsional)
                  style: TextStyle(
                    fontWeight: unit.isPolres ? FontWeight.w800 : FontWeight.w600,
                    fontSize: unit.isPolres ? 15 : 14,
                    color: const Color(0xFF1F2937), // Cool Grey 800
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Ikon kecil untuk subtitle (opsional, menambah konteks)
                    Icon(
                      unit.isPolres ? Icons.person_outline : Icons.location_on_outlined,
                      size: 12,
                      color: const Color(0xFF6B7280), // Cool Grey 500
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        unit.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280), // Cool Grey 500
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // --- 3. BADGE STATUS (Dengan Ikon) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: unit.isPolres 
                  ? const Color(0xFFDBEAFE) // Blue 100
                  : const Color(0xFFF3F4F6), // Cool Grey 100
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: unit.isPolres 
                    ? const Color(0xFF93C5FD) 
                    : const Color(0xFFE5E7EB),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  unit.isPolres ? Icons.business : Icons.store_mall_directory,
                  size: 10,
                  color: unit.isPolres ? const Color(0xFF1E40AF) : const Color(0xFF4B5563),
                ),
                const SizedBox(width: 4),
                Text(
                  unit.count,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: unit.isPolres 
                        ? const Color(0xFF1E40AF) // Blue 800
                        : const Color(0xFF4B5563), // Grey 700
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}