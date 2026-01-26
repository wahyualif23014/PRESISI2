// Lokasi: lib/features/admin/main_data/jabatan/widgets/jabatan_list_item.dart

import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/main_data/positions/data/models/position_model.dart'; // Sesuaikan path jika beda

class JabatanListItem extends StatelessWidget {
  final JabatanModel item;
  final VoidCallback onToggleSelection;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const JabatanListItem({
    super.key,
    required this.item,
    required this.onToggleSelection,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Cek apakah jabatan ini sudah terisi pejabat
    final hasPejabat = item.namaPejabat != null && item.namaPejabat!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: InkWell(
        onTap: onToggleSelection,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // 1. Checkbox Selection
              _buildCheckbox(),
              
              const SizedBox(width: 12),

              // 2. Informasi Jabatan (Kiri)
              Expanded(
                flex: 4,
                child: Text(
                  item.namaJabatan,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 3. Informasi Pejabat & Actions (Kanan)
              if (hasPejabat) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      // Detail Pejabat
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.namaPejabat!,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "NRP: ${item.nrp ?? '-'}", // Tampilkan NRP dari Dummy
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Action Buttons
                      _ActionIcon(
                        icon: Icons.edit_outlined, 
                        color: Colors.blue, 
                        onTap: onEdit
                      ),
                      const SizedBox(width: 6),
                      _ActionIcon(
                        icon: Icons.delete_outline, 
                        color: Colors.red, 
                        onTap: onDelete
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Transform.scale(
      scale: 1.1,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Checkbox(
          value: item.isSelected,
          onChanged: (_) => onToggleSelection(),
          activeColor: const Color(0xFF7C4DFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          side: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
      ),
    );
  }
}

// Widget kecil terpisah untuk tombol aksi agar kode utama bersih
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(4),
          color: color.withOpacity(0.05), // Sedikit background tint
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}