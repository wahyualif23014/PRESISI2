import 'package:flutter/material.dart';

class RecapTableHeader extends StatelessWidget {
  const RecapTableHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        // Memberikan bayangan halus agar header terlihat terpisah dari list
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
        border: const Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: const [
          // Nama Wilayah (Polres/Polsek/Desa)
          Expanded(flex: 3, child: Text("WILAYAH", style: _headerStyle)),

          // Potensi Lahan
          Expanded(
            flex: 2,
            child: Text(
              "POTENSI",
              style: _headerStyle,
              textAlign: TextAlign.center,
            ),
          ),

          // Luas Tanam
          Expanded(
            flex: 2,
            child: Text(
              "TANAM",
              style: _headerStyle,
              textAlign: TextAlign.center,
            ),
          ),

          // Data Panen (Gabungan Luas & Tonase)
          Expanded(
            flex: 3,
            child: Text(
              "PANEN",
              style: _headerStyle,
              textAlign: TextAlign.center,
            ),
          ),

          // Serapan / Distribusi
          Expanded(
            flex: 2,
            child: Text(
              "SERAPAN",
              style: _headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Gaya teks header yang ringkas dan tegas
const TextStyle _headerStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w800,
  color: Color(0xFF666666),
  letterSpacing: 0.5,
);
