import 'package:flutter/material.dart';

class PersonelSectionHeader extends StatelessWidget {
  final String title;

  const PersonelSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Memberi napas vertikal
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, 
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(width: 8),

          // 2. Judul Section (Unit Kerja)
          Text(
            title.toUpperCase(), 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey.shade700,
              letterSpacing: 0.5, 
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Divider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}