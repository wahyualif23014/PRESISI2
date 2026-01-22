import 'package:flutter/material.dart';

class RecapHeaderSection extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onPrintTap;

  const RecapHeaderSection({
    Key? key,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.onPrintTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // --- 1. SEARCH BAR ---
          Expanded(
            child: Container(
              height: 48, // Tinggi yang pas
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 4), // Efek bayangan ke bawah
                  ),
                ],
              ),
              child: TextField(
                onChanged: onSearchChanged,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  hintText: "Cari Data",
                  hintStyle: TextStyle(
                    color: Colors.black87, 
                    fontWeight: FontWeight.w600
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.black87, size: 28),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12), // Jarak antara Search dan Filter

          _buildActionButton(
            icon: Icons.filter_alt,
            color: const Color(0xFF0097B2), // Sesuaikan kode warna Hex biru/cyan
            onTap: onFilterTap,
          ),

          const SizedBox(width: 12), // Jarak antara Filter dan Print

          _buildActionButton(
            icon: Icons.print,
            color: const Color(0xFFFF9100),
            onTap: onPrintTap,
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk tombol kotak (Filter & Print)
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8), // Sudut sedikit membulat
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}