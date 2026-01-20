// Lokasi: lib/features/admin/main_data/regions/presentation/widgets/wilayah_group_headers.dart

import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// HEADER LEVEL 1: KABUPATEN
// -----------------------------------------------------------------------------
class WilayahKabupatenHeader extends StatelessWidget {
  final String title;
  final bool isExpanded;     // Status apakah sedang terbuka
  final VoidCallback onTap;  // Aksi saat header diklik

  const WilayahKabupatenHeader({
    super.key, 
    required this.title,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD1C4E9), // Deep Purple 100
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Ikon Panah (Indikator)
              AnimatedRotation(
                turns: isExpanded ? 0.0 : -0.25, // 0 = Bawah, -0.25 = Kanan (90 derajat)
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Color(0xFF4527A0),
                ),
              ),
              const SizedBox(width: 8),

              // Judul Kabupaten
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800, // Lebih tebal dari kecamatan
                    fontSize: 13,
                    color: Color(0xFF4527A0), // Deep Purple 800
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HEADER LEVEL 2: KECAMATAN
// -----------------------------------------------------------------------------
class WilayahKecamatanHeader extends StatelessWidget {
  final String title;
  final bool isExpanded;     // Status apakah desa di bawahnya terlihat
  final VoidCallback onTap;  // Aksi saat header diklik

  const WilayahKecamatanHeader({
    super.key, 
    required this.title,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEDE7F6), // Deep Purple 50
      child: InkWell(
        onTap: onTap,
        child: Container(
          // Tambahkan indentasi kiri (paddingLeft) agar terlihat sebagai anak dari Kabupaten
          padding: const EdgeInsets.only(left: 32, right: 12, top: 10, bottom: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFD1C4E9), width: 0.5), // Garis tipis pemisah
            ),
          ),
          child: Row(
            children: [
              // Ikon Panah Kecil
              AnimatedRotation(
                turns: isExpanded ? 0.0 : -0.25,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF5E35B1),
                ),
              ),
              const SizedBox(width: 8),

              // Judul Kecamatan
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF5E35B1), // Deep Purple 600
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}