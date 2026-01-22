import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';

class RecapDataRow extends StatelessWidget {
  final RecapModel data;
  final VoidCallback? onTap; 
  final bool isExpanded;     

  const RecapDataRow({
    Key? key,
    required this.data,
    this.onTap,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Tentukan Warna Background berdasarkan Tipe
    Color getBackgroundColor() {
      switch (data.type) {
        case RecapRowType.polres:
          return const Color(0xFFE0E0F8); // Ungu agak gelap
        case RecapRowType.polsek:
          return const Color(0xFFF3F3FF); // Ungu sangat muda
        case RecapRowType.desa:
        default:
          return Colors.white;            // Putih
      }
    }

    // 2. Tentukan Ketebalan Font
    FontWeight getFontWeight() {
      switch (data.type) {
        case RecapRowType.polres:
          return FontWeight.w800; // Sangat Tebal
        case RecapRowType.polsek:
          return FontWeight.w600; // Agak Tebal
        case RecapRowType.desa:
        default:
          return FontWeight.w400; // Biasa
      }
    }

    // 3. Tentukan Indentasi (Jarak Kiri) untuk Nama Wilayah
    double getIndent() {
      switch (data.type) {
        case RecapRowType.polres:
          return 0.0;
        case RecapRowType.polsek:
          return 16.0; // Menjorok dikit
        case RecapRowType.desa:
          return 32.0; // Menjorok banyak
        default:
          return 0.0;
      }
    }

    // Style Dasar Text
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: getFontWeight(),
      color: Colors.black87,
    );

    // Cek apakah baris ini bisa di-expand (Polres & Polsek)
    final bool isExpandable = data.type != RecapRowType.desa;

    return Material(
      color: getBackgroundColor(),
      child: InkWell(
        // Desa tidak perlu onTap expand/collapse
        onTap: isExpandable ? onTap : null, 
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
          ),
          child: Row(
            children: [
              // --- 1. NAMA WILAYAH (DENGAN INDENTASI & ICON) ---
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // Spasi indentasi sesuai level
                    SizedBox(width: getIndent()),

                    // Ikon Panah (Hanya untuk Polres & Polsek)
                    if (isExpandable)
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(
                          isExpanded 
                              ? Icons.keyboard_arrow_down 
                              : Icons.keyboard_arrow_right,
                          size: 16,
                          color: Colors.black54,
                        ),
                      )
                    else
                      // Jika Desa, berikan spasi kosong pengganti ikon agar teks rata
                      const SizedBox(width: 20), 

                    // Teks Nama Wilayah
                    Expanded(
                      child: Text(
                        data.namaWilayah, 
                        style: textStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. DATA ANGKA (Rata Tengah) ---
              Expanded(
                flex: 2,
                child: Text(
                  "${data.potensiLahan.toInt()} HA", 
                  style: textStyle, 
                  textAlign: TextAlign.center
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "${data.tanamLahan.toInt()} HA", 
                  style: textStyle, 
                  textAlign: TextAlign.center
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  data.panenDisplay, 
                  style: textStyle, 
                  textAlign: TextAlign.center
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "${data.serapan.toInt()} HA", 
                  style: textStyle, 
                  textAlign: TextAlign.center
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}