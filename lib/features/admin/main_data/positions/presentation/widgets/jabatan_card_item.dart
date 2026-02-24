import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/models/position_model.dart';

// Definisi palet warna profesional
const Color _forestGreen = Color(0xFF2D4F1E);
const Color _warmBeige = Color(0xFFF8F4EE); // Lebih terang untuk kesan bersih
const Color _terracotta = Color(0xFFE27D60);
const Color _slateGrey = Color(0xFF636E72);
const Color _bgCard = Colors.white;
const Color _textPrimary = Color(0xFF2D3436);
const Color _border = Color(0xFFDFE6E9);
const Color _activeColor = _forestGreen; // Menggunakan Green sebagai warna utama aktif

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

  @override
  Widget build(BuildContext context) {
    // Berdasarkan DB Anda, kita cek IdAnggota untuk status keterisian
    final bool isFilled = item.idAnggota != null; 

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16), // Radius lebih modern
        border: Border.all(
          color: item.isSelected ? _activeColor : _border,
          width: item.isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header: Visual Jabatan
            Expanded(
              flex: 4,
              child: _HeaderSection(item: item, isFilled: isFilled),
            ),
            
            // Body: Informasi Nama Jabatan
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusBadge(isFilled: isFilled),
                    const SizedBox(height: 8),
                    Text(
                      item.namaJabatan.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    _IdInfo(id: item.id),
                  ],
                ),
              ),
            ),

            // Action Bar: Controls
            _ActionBar(
              isSelected: item.isSelected,
              onToggle: onToggleSelection,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final JabatanModel item;
  final bool isFilled;
  const _HeaderSection({required this.item, required this.isFilled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _warmBeige,
            _warmBeige.withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Icon Pattern
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(Icons.work_outline, size: 60, color: _forestGreen.withOpacity(0.05)),
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: isFilled ? _forestGreen.withOpacity(0.1) : Colors.white,
            child: Icon(
              isFilled ? Icons.verified_user_rounded : Icons.account_circle_outlined,
              color: isFilled ? _forestGreen : _slateGrey.withOpacity(0.3),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isFilled;
  const _StatusBadge({required this.isFilled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFilled ? _forestGreen.withOpacity(0.1) : _terracotta.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? _forestGreen : _terracotta,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isFilled ? "AKTIF" : "VACANT",
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: isFilled ? _forestGreen : _terracotta,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdInfo extends StatelessWidget {
  final int id;
  const _IdInfo({required this.id});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.fingerprint, size: 12, color: _slateGrey.withOpacity(0.5)),
        const SizedBox(width: 4),
        Text(
          "ID: $id",
          style: TextStyle(
            fontSize: 10,
            color: _slateGrey.withOpacity(0.6),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onToggle, onEdit, onDelete;

  const _ActionBar({
    required this.isSelected,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFDFD),
        border: Border(top: BorderSide(color: _border, width: 0.8)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: isSelected ? _activeColor : _slateGrey.withOpacity(0.4),
              size: 22,
            ),
          ),
          const Spacer(),
          _CircleActionButton(
            icon: Icons.edit_note_rounded,
            color: _forestGreen,
            onTap: onEdit,
          ),
          const SizedBox(width: 8),
          _CircleActionButton(
            icon: Icons.delete_outline_rounded,
            color: _terracotta,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CircleActionButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}