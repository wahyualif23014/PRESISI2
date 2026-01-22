import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';

class RecapDataRow extends StatelessWidget {
  final RecapModel data;
  final VoidCallback? onTap; // Tambahan: Fungsi saat diklik
  final bool isExpanded;     // Tambahan: Status panah (atas/bawah)

  const RecapDataRow({
    Key? key,
    required this.data,
    this.onTap,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Logika Warna
    final bgColor = data.isHeader ? const Color(0xFFE0E0F8) : Colors.white;
    
    // Logika Font
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: data.isHeader ? FontWeight.bold : FontWeight.w500,
      color: Colors.black87,
    );

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: data.isHeader ? onTap : null, // Hanya header yang bisa diklik
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
          ),
          child: Row(
            children: [
              // 1. Nama Wilayah (Update: Tambah Ikon Panah)
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    if (data.isHeader)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                          size: 16,
                          color: Colors.black54,
                        ),
                      ),
                    Expanded(child: Text(data.namaWilayah, style: textStyle)),
                  ],
                ),
              ),
              // 2. Potensi
              Expanded(
                flex: 2,
                child: Text("${data.potensiLahan.toInt()} HA", style: textStyle, textAlign: TextAlign.center),
              ),
              // 3. Tanam
              Expanded(
                flex: 2,
                child: Text("${data.tanamLahan.toInt()} HA", style: textStyle, textAlign: TextAlign.center),
              ),
              // 4. Panen
              Expanded(
                flex: 3,
                child: Text(data.panenDisplay, style: textStyle, textAlign: TextAlign.center),
              ),
              // 5. Serapan
              Expanded(
                flex: 2,
                child: Text("${data.serapan.toInt()} HA", style: textStyle, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}