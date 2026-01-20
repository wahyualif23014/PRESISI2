import 'package:flutter/material.dart';

class WilayahInfoBanner extends StatelessWidget {
  final int totalCount;
  final VoidCallback onClose;

  const WilayahInfoBanner({
    super.key,
    required this.totalCount,
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
          // Icon Info (Lingkaran Hitam dengan huruf i)
          const Icon(Icons.info, size: 20, color: Colors.black87),
          const SizedBox(width: 8),

          // Teks Informasi
          Expanded(
            child: Text(
              "TERDAPAT $totalCount KELURAHAN / DESA",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Tombol Close (X Merah/Hitam - di gambar terlihat merah/orange)
          InkWell(
            onTap: onClose,
            child: const Icon(
              Icons.close,
              color: Colors.deepOrange, // Warna silang
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}