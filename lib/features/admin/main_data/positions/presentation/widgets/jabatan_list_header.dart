// Lokasi: lib/features/admin/main_data/jabatan/widgets/jabatan_list_header.dart

import 'package:flutter/material.dart';

class JabatanListHeader extends StatelessWidget {
  final bool? isChecked;
  final ValueChanged<bool?> onCheckChanged;

  const JabatanListHeader({
    super.key,
    required this.isChecked,
    required this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Checkbox Master
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: isChecked,
              onChanged: onCheckChanged,
              activeColor: const Color(0xFF7C4DFF), // Ungu sesuai tema
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              side: BorderSide(color: Colors.grey.shade400, width: 1.5),
            ),
          ),
          const SizedBox(width: 8),
          
          // Label Header
          const Text(
            "NAMA JABATAN",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF374151), // Cool Gray 700
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}