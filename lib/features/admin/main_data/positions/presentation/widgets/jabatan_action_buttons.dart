// Lokasi: lib/features/admin/main_data/jabatan/widgets/jabatan_action_buttons.dart

import 'package:flutter/material.dart';

class JabatanActionButtons extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const JabatanActionButtons({
    super.key,
    required this.onAdd,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tombol ADD (Biru Cyan)
        Expanded(
          child: _buildButton(
            label: "Add",
            icon: Icons.add,
            color: const Color(0xFF00ACC1), // Cyan 600
            onTap: onAdd,
          ),
        ),
        const SizedBox(width: 4),

        // Tombol DELETE (Merah)
        Expanded(
          child: _buildButton(
            label: "Delete",
            icon: Icons.delete_outline,
            color: const Color(0xFFD50000), // Red Accent
            onTap: onDelete,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 45, // Tinggi seragam dengan search bar
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero, // Agar muat di layar kecil
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13, // Font sedikit dikecilkan agar muat
          ),
        ),
      ),
    );
  }
}