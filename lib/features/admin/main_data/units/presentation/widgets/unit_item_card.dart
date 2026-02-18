import 'package:flutter/material.dart';
import '../../data/models/unit_model.dart';

class UnitItemCard extends StatelessWidget {
  final UnitModel unit;
  final bool isExpanded;
  final VoidCallback? onExpandTap;

  const UnitItemCard({
    super.key,
    required this.unit,
    this.isExpanded = false,
    this.onExpandTap,
  });

  @override
  Widget build(BuildContext context) {
    // Menentukan warna background dan margin berdasarkan apakah ini Induk (Polres) atau Anak (Polsek)
    final bgColor = unit.isPolres ? Colors.white : Colors.grey[50];
    final margin =
        unit.isPolres
            ? const EdgeInsets.only(bottom: 0)
            : const EdgeInsets.only(left: 16, right: 0, top: 1);
    final elevation = unit.isPolres ? 1.0 : 0.0;

    return Card(
      margin: margin,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: bgColor,
      child: InkWell(
        onTap: onExpandTap, // Aksi ketika card diklik
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. JUDUL (Nama Satuan)
                    Text(
                      unit.title, // Contoh: POLRES GRESIK
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                      maxLines: 1, // Batasi 1 baris
                      overflow:
                          TextOverflow.ellipsis, // Jika kepanjangan kasih ...
                    ),

                    const SizedBox(height: 4),

                    // 2. SUBJUDUL (Nama Pejabat & HP)
                    Text(
                      unit.subtitle, // Contoh: Ka: AKBP Budi...
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.2, // Jarak antar baris jika 2 baris
                      ),
                      maxLines:
                          2, // Maksimal 2 baris untuk nama pejabat yang panjang
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // 3. INFO TAMBAHAN (Wilayah / Kode)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            unit.isPolres ? Colors.blue[50] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        unit.count, // Contoh: WILAYAH GRESIK
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color:
                              unit.isPolres
                                  ? Colors.blue[700]
                                  : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // --- BAGIAN IKON PANAH (Hanya untuk Polres) ---
              if (unit.isPolres) ...[
                const SizedBox(width: 16),
                // Ikon yang berputar jika di-expand
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0, // Rotasi 180 derajat
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}