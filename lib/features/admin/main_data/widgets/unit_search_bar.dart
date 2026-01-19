import 'package:flutter/material.dart';

class UnitSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const UnitSearchBar({
    super.key, 
    required this.controller, 
    required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade100, width: 1.5), // Gaya desain sesuai gambar
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: "Cari Data Polres Atau Polsek",
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: Icon(Icons.search, color: Colors.purple, size: 22),
          border: InputBorder.none, // Menghapus garis bawah default
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}