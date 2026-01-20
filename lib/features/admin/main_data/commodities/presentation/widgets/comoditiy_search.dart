import 'package:flutter/material.dart';

class ComoditiSearch extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  const ComoditiSearch({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Warna Tema
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
              style: const TextStyle(color: Colors.black87),
              decoration: const InputDecoration(
                hintText: "Cari Data",
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
        
        const SizedBox(width: 12), // Jarak antar Search dan Tombol

        // 2. TOMBOL ADD (Cyan)
        _buildButton(
          label: "Add",
          icon: Icons.add,
          color: const Color(0xFF00ACC1), // Cyan 600
          onTap: onAdd,
        ),

        const SizedBox(width: 8),

        // 3. TOMBOL DELETE (Merah)
        _buildButton(
          label: "Delete",
          icon: Icons.delete_outline,
          color: const Color(0xFFD50000), // Red Accent
          onTap: onDelete,
        ),
      ],
    );
  }

  // Helper Widget untuk membuat tombol seragam
  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 45,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}