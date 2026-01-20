import 'package:flutter/material.dart';

class ComoditiyBanner extends StatelessWidget {
  final int totalTypes; // Parameter baru: Jumlah Group/Jenis
  final int totalItems; // Parameter baru: Jumlah Total Data
  final VoidCallback onClose;

  const ComoditiyBanner({
    super.key,
    required this.totalTypes,
    required this.totalItems,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300, // Abu-abu background
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
      ),
      child: Row(
        children: [
          // -----------------------------------------------------------
          // BAGIAN 1: TOTAL JENIS (GROUP)
          // -----------------------------------------------------------
          const Icon(Icons.info, size: 16, color: Colors.black87),
          const SizedBox(width: 4),
          Text(
            "TERDAPAT $totalTypes JENIS KOMODITI",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10, // Font kecil agar muat dalam satu baris
              color: Colors.black87,
            ),
          ),

          // -----------------------------------------------------------
          // SEPARATOR (GARIS TEGAK)
          // -----------------------------------------------------------
          Container(
            height: 14,
            width: 1.5,
            color: Colors.black54,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // -----------------------------------------------------------
          // BAGIAN 2: TOTAL ITEM (KOMODITI)
          // -----------------------------------------------------------
          const Icon(Icons.info, size: 16, color: Colors.black87),
          const SizedBox(width: 4),
          
          // Gunakan Expanded agar teks panjang otomatis terpotong rapi jika layar sempit
          Expanded( 
            child: Text(
              "TERDAPAT $totalItems KOMODITI LAHAN",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // -----------------------------------------------------------
          // TOMBOL CLOSE
          // -----------------------------------------------------------
          InkWell(
            onTap: onClose,
            child: const Icon(
              Icons.close,
              color: Colors.deepOrange,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}