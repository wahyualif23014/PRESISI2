import 'package:flutter/material.dart';

class WilayahSearchFilter extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const WilayahSearchFilter({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    // Warna Tema Ungu (Sesuai Screenshot)
    const purpleColor = Color(0xFF7C4DFF);
    const bgPurpleLight = Color(0xFFF3F0FF);

    return Row(
      children: [
        // 1. SEARCH BAR (Flexible Width)
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: bgPurpleLight, // Background Ungu Muda
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: purpleColor, width: 1.5),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: "Cari Wilayah",
                hintStyle: TextStyle(
                  color: purpleColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: purpleColor),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12), // Jarak antar Search dan Filter

        // 2. FILTER BUTTON (Fixed Width)
        SizedBox(
          height: 45,
          child: ElevatedButton.icon(
            onPressed: onFilterTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // Background Putih
              foregroundColor: purpleColor,  // Text & Icon Ungu
              elevation: 0,
              side: const BorderSide(color: purpleColor, width: 1.5), // Border Ungu
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            // Menggunakan icon filter (corong)
            icon: const Icon(Icons.filter_alt, size: 20), 
            label: const Text(
              "Filter",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}