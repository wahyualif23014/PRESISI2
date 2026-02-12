import 'package:flutter/material.dart';

// HEADER LEVEL 1: KABUPATEN
class WilayahKabupatenHeader extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onTap;

  const WilayahKabupatenHeader({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD1C4E9), // Warna Asli: Deep Purple 100
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.deepPurple.shade200, width: 1),
            ),
          ),
          child: Row(
            children: [
              AnimatedRotation(
                turns: isExpanded ? 0.0 : -0.25,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title, // Nama Kabupaten
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.deepPurple,
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

// HEADER LEVEL 2: KECAMATAN
class WilayahKecamatanHeader extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onTap;

  const WilayahKecamatanHeader({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEDE7F6), // Warna Asli: Deep Purple 50
      child: InkWell(
        onTap: onTap,
        child: Container(
          // Indentasi kiri agar terlihat hierarkinya
          padding: const EdgeInsets.only(
            left: 32,
            right: 12,
            top: 10,
            bottom: 10,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFD1C4E9), width: 0.5),
            ),
          ),
          child: Row(
            children: [
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
              Expanded(
                child: Text(
                  title, // Nama Kecamatan
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF5E35B1),
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
