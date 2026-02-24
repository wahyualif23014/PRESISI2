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
      height: 48, 
      decoration: BoxDecoration(
        color: Colors.white, // Background Putih
        borderRadius: BorderRadius.circular(12), // Radius konsisten 12
        border: Border.all(
          color: Colors.black, // Border Hitam
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 4), // Efek bayangan konsisten
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(color: Colors.black87),
        decoration: const InputDecoration(
          hintText: "Cari Data",
          hintStyle: TextStyle(
            color: Colors.black87, // Warna hint Hitam
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black87, // Ikon Hitam
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 9),
        ),
      ),
    );
  }
}