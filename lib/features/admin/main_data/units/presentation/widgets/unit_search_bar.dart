import 'package:flutter/material.dart';

class UnitSearchFilter extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const UnitSearchFilter({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged:
                  onChanged, // INI KUNCINYA (Meneruskan ketikan ke Provider)
              // --- Tambahan Optimasi UX ---
              autocorrect:
                  false, // Matikan koreksi otomatis (mengganggu untuk nama daerah)
              enableSuggestions: false,
              textInputAction:
                  TextInputAction.search, // Tombol enter jadi kaca pembesar
              textAlignVertical: TextAlignVertical.center,

              // -----------------------------
              style: const TextStyle(color: Colors.black87),
              decoration: const InputDecoration(
                hintText: "Cari Data Polres Atau Polsek",
                hintStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.black87, size: 24),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Tombol Filter (Tetap sama seperti kode Anda)
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF0097B2),
            borderRadius: BorderRadius.circular(12),
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
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_alt, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Filter",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
