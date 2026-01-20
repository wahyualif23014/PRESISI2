// Lokasi: lib/features/admin/main_data/jabatan/widgets/jabatan_list_item.dart

import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/main_data/positions/data/models/position_model.dart';

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
    final hasPejabat = item.namaPejabat != null && item.namaPejabat!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: InkWell(
        onTap: onToggleSelection, // Klik baris = centang checkbox
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Checkbox (Hanya indikator visual, logic di parent)
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: item.isSelected,
                  onChanged: (val) => onToggleSelection(),
                  activeColor: const Color(0xFF7C4DFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                ),
              ),
              const SizedBox(width: 8),

              // 2. Nama Jabatan (Kiri)
              Expanded(
                flex: 3,
                child: Text(
                  item.namaJabatan,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),

              // 3. Info Pejabat & Actions (Kanan - Hanya jika ada data)
              if (hasPejabat) ...[
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nama Pejabat
                      Text(
                        item.namaPejabat!,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10, // Font kecil sesuai gambar
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Tanggal Update
                      Text(
                        item.lastUpdated ?? "-",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Action Icons (Edit & Delete Kecil)
                _buildActionIcon(Icons.edit_square, Colors.blue, onEdit),
                const SizedBox(width: 4),
                _buildActionIcon(Icons.delete, Colors.red, onDelete),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk ikon kecil kotak
  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 14,
          color: color,
        ),
      ),
    );
  }
}