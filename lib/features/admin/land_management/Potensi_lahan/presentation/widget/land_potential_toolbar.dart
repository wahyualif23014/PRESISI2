import 'package:flutter/material.dart';

class LandPotentialToolbar extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onAddTap;

  const LandPotentialToolbar({
    super.key,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // Padding sekeliling toolbar
      color: Colors.white,
      child: Row(
        children: [
          // ==============================
          // 1. SEARCH BAR (Flexible Width)
          // ==============================
          Expanded(
            child: SizedBox(
              height: 40, // Tinggi disamakan dengan tombol
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari Data Lahan',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.black54),
                  prefixIcon: const Icon(Icons.search, color: Colors.black87, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black54),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black87),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),

          // ==============================
          // 2. TOMBOL FILTER (Blue)
          // ==============================
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: onFilterTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0097A7), // Warna Biru Cyan (Sesuai gambar)
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.filter_alt, size: 18),
              label: const Text(
                "Filter Data",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ==============================
          // 3. TOMBOL TAMBAH (Green)
          // ==============================
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: onAddTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853), // Warna Hijau (Sesuai gambar)
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                "Tambah Data",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}