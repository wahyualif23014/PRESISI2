import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/main_data/positions/data/models/position_model.dart';

class JabatanCardItem extends StatelessWidget {
  final JabatanModel item;
  final VoidCallback onToggleSelection;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const JabatanCardItem({
    super.key,
    required this.item,
    required this.onToggleSelection,
    required this.onEdit,
    required this.onDelete,
  });

  // --- PALET WARNA (Slate / Blue-Grey Theme) ---
  static const Color _bgCard = Colors.white;
  static const Color _border = Color(0xFFE2E8F0); // Slate 200
  static const Color _textPrimary = Color(0xFF1E293B); // Slate 800
  static const Color _textSecondary = Color(0xFF64748B); // Slate 500
  static const Color _accentColor = Color(0xFF334155); // Slate 700
  static const Color _activeColor = Color(0xFF6366F1); // Indigo (untuk check)

  @override
  Widget build(BuildContext context) {
    // Cek apakah jabatan terisi
    final bool hasPejabat = item.namaPejabat != null && item.namaPejabat!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16), // Sudut tumpul modern
        border: Border.all(
            color: item.isSelected ? _activeColor : _border,
            width: item.isSelected ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06), // Shadow halus
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. HEADER IMAGE (Foto + Expand Logic)
          Expanded(
            flex: 4,
            child: _HeaderImageSection(
              item: item,
              hasPejabat: hasPejabat,
            ),
          ),

          // 2. INFO CONTENT
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Jabatan (Prioritas Utama)
                  Text(
                    item.namaJabatan,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Garis Pemisah Kecil
                  Container(
                    width: 24,
                    height: 2,
                    color: _border,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  // Info Pejabat
                  if (hasPejabat) ...[
                    Text(
                      item.namaPejabat!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "NRP: ${item.nrp ?? '-'}",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: _textSecondary,
                      ),
                    ),
                  ] else
                    const Text(
                      "Jabatan Kosong",
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.redAccent,
                      ),
                    ),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // 3. ACTION BAR (Checkbox & Buttons)
          _ActionBar(
            item: item,
            onToggle: onToggleSelection,
            onEdit: onEdit,
            onDelete: onDelete,
            activeColor: _activeColor,
            borderColor: _border,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGETS (Clean Architecture: UI Separation)
// =============================================================================

class _HeaderImageSection extends StatelessWidget {
  final JabatanModel item;
  final bool hasPejabat;

  const _HeaderImageSection({
    required this.item,
    required this.hasPejabat,
  });

  void _expandImage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.8),
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => _ExpandedImageViewer(
          heroTag: "img_${item.id}", // ID Unik untuk Hero
          initials: _getInitials(item.namaPejabat),
          name: item.namaPejabat ?? "",
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return "?";
    List<String> parts = name.trim().split(" ");
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasPejabat ? () => _expandImage(context) : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Container Rounded Top
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Hero(
              tag: "img_${item.id}", // Kunci Animasi Smooth
              child: Material(
                color: Colors.transparent,
                child: Container(
                  color: hasPejabat
                      ? const Color(0xFFCBD5E1) // Slate 300
                      : const Color(0xFFF1F5F9), // Slate 100
                  child: Center(
                    child: hasPejabat
                        ? Text(
                            _getInitials(item.namaPejabat),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF475569), // Slate 600
                            ),
                          )
                        : Icon(
                            Icons.person_off_rounded,
                            color: Colors.grey.shade400,
                            size: 32,
                          ),
                  ),
                ),
              ),
            ),
          ),
          // Gradient Overlay agar teks putih terbaca (opsional jika pakai foto asli)
          if (hasPejabat)
            Positioned(
              right: 8,
              top: 8,
              child: Icon(
                Icons.fullscreen,
                color: Colors.black.withOpacity(0.3),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final JabatanModel item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color activeColor;
  final Color borderColor;

  const _ActionBar({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.activeColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
        color: const Color(0xFFF8FAFC), // Slate 50 (Very Light Grey)
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Checkbox Custom
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                item.isSelected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: item.isSelected ? activeColor : Colors.grey.shade400,
                size: 22,
              ),
            ),
          ),
          // Action Buttons
          Row(
            children: [
              _MiniIconButton(
                icon: Icons.edit_rounded,
                color: Colors.blue.shade600,
                onTap: onEdit,
              ),
              const SizedBox(width: 4),
              _MiniIconButton(
                icon: Icons.delete_rounded,
                color: Colors.red.shade400,
                onTap: onDelete,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MiniIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// =============================================================================
// POPUP IMAGE VIEWER (Smooth Expand)
// =============================================================================

class _ExpandedImageViewer extends StatelessWidget {
  final String heroTag;
  final String initials;
  final String name;

  const _ExpandedImageViewer({
    required this.heroTag,
    required this.initials,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hero Widget untuk transisi mulus
            Hero(
              tag: heroTag,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0), // Slate 200
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nama Pejabat di bawah foto saat expand
            Material(
              color: Colors.transparent,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Tombol Close
            FloatingActionButton.small(
              backgroundColor: Colors.white,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}