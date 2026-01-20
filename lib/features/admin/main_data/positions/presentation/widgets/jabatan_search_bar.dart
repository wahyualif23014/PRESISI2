// Lokasi: lib/features/admin/main_data/jabatan/widgets/jabatan_search_bar.dart

import 'package:flutter/material.dart';

class JabatanSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const JabatanSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45, // Tinggi disesuaikan dengan desain tombol di sebelahnya
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF), // Warna ungu sangat muda (Background)
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF7C4DFF), // Warna ungu border
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black87),
        decoration: const InputDecoration(
          hintText: "Cari Data",
          hintStyle: TextStyle(
            color: Color(0xFF7C4DFF), // Warna hint ungu
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Color(0xFF7C4DFF), // Ikon ungu
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 9),
        ),
      ),
    );
  }
}