import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk fitur Copy Paste
import 'package:sdmapp/features/admin/main_data/regions/data/models/region_model.dart';

class WilayahListItem extends StatelessWidget {
  final WilayahModel item;
  final VoidCallback? onEditTap;
  final VoidCallback? onLocationTap; // Callback baru untuk icon lokasi

  const WilayahListItem({
    super.key, 
    required this.item,
    this.onEditTap,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      padding: EdgeInsets.zero, 
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. NAMA DESA (Flex 4 - Lebih Luas)
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () => _showDetailPopup(context), // Klik nama untuk lihat detail Lat/Long
                child: _DataCell(
                  align: Alignment.centerLeft,
                  paddingLeft: 12,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.namaDesa,
                          style: const TextStyle(
                            fontSize: 12, // Font sedikit diperbesar karena ruang luas
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline, // Visual cue bahwa ini bisa diklik
                            decorationStyle: TextDecorationStyle.dotted,
                            decorationColor: Colors.grey,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.info_outline, size: 14, color: Colors.grey.shade400) // Icon hint
                    ],
                  ),
                ),
              ),
            ),
            
            const _Separator(),

            // 2. PROSES / UPDATE INFO (Flex 4 - Lebih Luas)
            Expanded(
              flex: 4,
              child: _DataCell(
                align: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.updatedBy,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 10,
                        color: Colors.black87
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.lastUpdated,
                      style: TextStyle(
                        fontSize: 10, 
                        color: Colors.grey.shade600
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const _Separator(),

            // 3. AKSI (Flex 2 - Cukup untuk 2 tombol)
            Expanded(
              flex: 2,
              child: _DataCell(
                align: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol A: Lokasi (Hijau)
                    _ActionButton(
                      icon: Icons.location_on,
                      color: Colors.green,
                      tooltip: "Lihat Peta",
                      onTap: onLocationTap ?? () {},
                    ),
                    
                    const SizedBox(width: 8), // Jarak antar tombol
                    
                    // Tombol B: Edit (Biru)
                    _ActionButton(
                      icon: Icons.edit_square,
                      color: Colors.blue,
                      tooltip: "Edit Data",
                      onTap: onEditTap ?? () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIC POPUP DETAIL ---
  void _showDetailPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(item.namaDesa, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCopyRow(ctx, "Latitude", item.latitude.toString()),
              const Divider(),
              _buildCopyRow(ctx, "Longitude", item.longitude.toString()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Tutup"),
            )
          ],
        );
      },
    );
  }

  // Widget Baris di dalam Popup dengan fitur Copy
  Widget _buildCopyRow(BuildContext context, String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
      trailing: IconButton(
        icon: const Icon(Icons.copy, color: Colors.blue),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$label berhasil disalin!"), duration: const Duration(seconds: 1)),
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

// Widget Tombol Aksi Kecil
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), // Background tipis biar terlihat clickable
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();
  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      color: Colors.grey.shade200, 
      thickness: 1, width: 1, indent: 4, endIndent: 4,
    );
  }
}

class _DataCell extends StatelessWidget {
  final Widget child;
  final Alignment align;
  final double paddingLeft;

  const _DataCell({required this.child, required this.align, this.paddingLeft = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: align,
      padding: EdgeInsets.only(
        left: align == Alignment.centerLeft ? (paddingLeft > 0 ? paddingLeft : 12) : 4,
        right: 4, top: 10, bottom: 10,
      ),
      child: child,
    );
  }
}