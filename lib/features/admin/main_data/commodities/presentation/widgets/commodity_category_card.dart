import 'package:flutter/material.dart';
import '../../data/models/commodity_category_model.dart';

class CommodityCategoryCard extends StatelessWidget {
  final CommodityCategoryModel item;
  final VoidCallback onViewAllTap;

  const CommodityCategoryCard({
    super.key,
    required this.item,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. KOTAK ICON (FOTO RUSAK)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200], // Latar abu-abu
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              // Icon Foto Rusak sesuai permintaan
              child: Icon(
                Icons.broken_image_outlined,
                size: 32,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 2. KONTEN TENGAH
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul Kategori
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),

                // DESKRIPSI DIHAPUS (Kosong)
                const SizedBox(height: 8),

                // Tags / Chips (3 Item Awal)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      item.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7), // Kuning muda
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFFCD34D),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E), // Coklat
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),

          // 3. TOMBOL PANAH KANAN
          InkWell(
            onTap: onViewAllTap,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
