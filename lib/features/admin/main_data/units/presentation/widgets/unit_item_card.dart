// Lokasi: lib/features/admin/main_data/units/widgets/unit_item_card.dart

import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/data/models/unit_model.dart';
// Pastikan import ini mengarah ke file UnitModel yang baru (yang ada class UnitModel-nya)

class UnitItemCard extends StatelessWidget {
  final UnitModel unit;
  final bool isExpanded;          // Diterima dari UnitRegion.isExpanded di halaman utama
  final VoidCallback? onExpandTap; // Callback untuk mengubah state UnitRegion

  const UnitItemCard({
    super.key,
    required this.unit,
    this.isExpanded = false,
    this.onExpandTap,
  });

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // KONFIGURASI TEMA (Tetap Sesuai Desain Professional)
    // -------------------------------------------------------------------------
    const primaryBlue = Color(0xFF1E40AF); // Blue 800
    const bgParent = Colors.white;
    const bgChild = Color(0xFFF9FAFB); // Cool Gray 50
    
    // Logika styling berdasarkan apakah ini Polres (Parent) atau Polsek (Child)
    final isParent = unit.isPolres;

    return Material(
      color: isParent ? bgParent : bgChild,
      child: InkWell(
        // Hanya Parent (Polres) yang bisa diklik untuk expand/collapse
        onTap: isParent ? onExpandTap : null, 
        child: Container(
          // Dekorasi Border
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
              // Marker kiri: Tebal Biru jika Parent, Tipis Abu jika Child
              left: isParent
                  ? const BorderSide(color: primaryBlue, width: 4) 
                  : BorderSide(color: Colors.grey.shade300, width: 1), 
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ---------------------------------------------------------------
              // 1. VISUAL HIERARCHY (POHON)
              // ---------------------------------------------------------------
              // Jika ini Child (Polsek), tampilkan garis konektor "L"
              if (!isParent) ...[
                SizedBox(
                  width: 24, 
                  height: 24,
                  child: CustomPaint(painter: _TreeConnectorPainter()),
                ),
                const SizedBox(width: 8),
              ],

              // ---------------------------------------------------------------
              // 2. AVATAR / INITIAL
              // ---------------------------------------------------------------
              _buildAvatar(unit.title, isParent),

              const SizedBox(width: 16),

              // ---------------------------------------------------------------
              // 3. KONTEN TEKS (Title & Subtitle)
              // ---------------------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      unit.title,
                      style: TextStyle(
                        fontWeight: isParent ? FontWeight.w700 : FontWeight.w600,
                        fontSize: isParent ? 15 : 14,
                        color: const Color(0xFF111827), // Gray 900
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            unit.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ---------------------------------------------------------------
              // 4. BADGE STATUS & INDICATOR
              // ---------------------------------------------------------------
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Badge Label Wilayah
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isParent 
                          ? const Color(0xFFEFF6FF) // Blue 50
                          : const Color(0xFFF3F4F6), // Gray 100
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isParent 
                            ? const Color(0xFFBFDBFE) // Blue 200
                            : const Color(0xFFE5E7EB), // Gray 200
                      ),
                    ),
                    child: Text(
                      unit.count, 
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isParent ? primaryBlue : Colors.grey.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  // Panah Rotasi (Hanya muncul jika Parent)
                  if (isParent) ...[
                    const SizedBox(height: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0, // 0.0 = Bawah, 0.5 = Atas
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk membuat Avatar Lingkaran
  Widget _buildAvatar(String title, bool isActive) {
    final String initial = title.isNotEmpty ? title[0].toUpperCase() : "?";

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E40AF) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isActive ? Colors.white : const Color(0xFF1E40AF),
          fontSize: 16,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PAINTER: MENGGAMBAR GARIS POHON (TREE CONNECTOR)
// -----------------------------------------------------------------------------
class _TreeConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    // 1. Mulai dari atas (seolah nyambung dari item sebelumnya)
    path.moveTo(0, -size.height); 
    // 2. Garis vertikal ke tengah
    path.lineTo(0, size.height / 2); 
    // 3. Garis horizontal ke kanan (ke arah Avatar)
    path.lineTo(size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}