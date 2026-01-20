import 'package:flutter/material.dart';

class WilayahTableHeader extends StatelessWidget {
  const WilayahTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEEEEE),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0), 
      child: IntrinsicHeight( 
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            // 1. NAMA (Flex 4) - Diperlebar
            const Expanded(
              flex: 4, 
              child: _HeaderCell("NAMA KELURAHAN / DESA", align: TextAlign.left, paddingLeft: 12),
            ),
            
            const _Separator(), // Sekat

            // 2. PROSES (Flex 4) - Diperlebar
            const Expanded(
              flex: 4, 
              child: _HeaderCell("PROSES", align: TextAlign.left),
            ),
            
            const _Separator(), // Sekat

            // 3. AKSI (Flex 2) - Diperlebar sedikit agar tombol muat
            const Expanded(
              flex: 2, 
              child: _HeaderCell("AKSI", align: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

// Widget untuk Garis Pemisah (Sekat)
class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      color: Colors.grey.shade400, 
      thickness: 1,               
      width: 1,                   
      indent: 8,                  
      endIndent: 8,               
    );
  }
}

// Widget untuk Cell Header
class _HeaderCell extends StatelessWidget {
  final String text;
  final TextAlign align;
  final double paddingLeft;

  const _HeaderCell(this.text, {this.align = TextAlign.left, this.paddingLeft = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: align == TextAlign.left ? (paddingLeft > 0 ? paddingLeft : 8) : 4,
        right: 4,
        top: 12,
        bottom: 12
      ),
      alignment: align == TextAlign.left ? Alignment.centerLeft : Alignment.center,
      child: Tooltip(
        message: text,
        child: Text(
          text,
          textAlign: align,
          maxLines: 2, 
          overflow: TextOverflow.ellipsis, 
          style: const TextStyle(
            fontSize: 10, 
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}