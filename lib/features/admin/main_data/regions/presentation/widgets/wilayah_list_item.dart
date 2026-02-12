import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/data/models/region_model.dart';

class WilayahListItem extends StatelessWidget {
  final WilayahModel item;
  final VoidCallback onEditTap; // Aksi Edit
  final VoidCallback onMapTap; // Aksi Buka Peta

  const WilayahListItem({
    super.key,
    required this.item,
    required this.onEditTap,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. DATA WILAYAH (Kiri)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_city,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "DESA / KELURAHAN",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Nama Desa
                InkWell(
                  onTap:
                      () => _copyToClipboard(
                        context,
                        "${item.latitude}, ${item.longitude}",
                      ),
                  child: Text(
                    item.namaDesa,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Koordinat & Info Update
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lat: ${item.latitude} • Long: ${item.longitude}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Update: ${item.lastUpdated} by ${item.updatedBy}",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. TOMBOL AKSI (Kanan)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Lokasi (Hijau/Google Maps Style)
              IconButton(
                onPressed: onMapTap,
                icon: const Icon(
                  Icons.map_outlined,
                  color: Colors.green,
                  size: 22,
                ),
                tooltip: "Lihat di Peta",
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),

              // Tombol Edit (Biru/Emas)
              IconButton(
                onPressed: onEditTap,
                icon: const Icon(
                  Icons.edit_location_alt_outlined,
                  color: Color(0xFFC0A100),
                  size: 22,
                ),
                tooltip: "Ubah Koordinat",
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Koordinat disalin"),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
