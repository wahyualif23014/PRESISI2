import 'package:flutter/material.dart';
import '../../data/model/land_potential_model.dart';
import 'land_detail_dialog.dart';

class LandPotentialCard extends StatelessWidget {
  final LandPotentialModel data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LandPotentialCard({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  // Base URL disesuaikan dengan endpoint API image di backend Go
  static const String _imageBaseUrl =
      "http://192.168.100.195:8080/api/potensi-lahan/image/";

  @override
  Widget build(BuildContext context) {
    // Penentuan warna berdasarkan status validasi
    final bool isValidated = data.statusValidasi == 'TERVALIDASI';
    final Color statusColor =
        isValidated ? const Color(0xFF1B9E5E) : Colors.orange;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- 1. FOTO LAHAN ---
                _buildThumbnail(),

                const SizedBox(width: 12),

                // --- 2. INFORMASI TENGAH (Personel & Alamat) ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.local_police_rounded,
                        data.policeName.isNotEmpty ? data.policeName : "-",
                        const Color(0xFF673AB7),
                        isBold: true,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.person_outline_rounded,
                        "PIC: ${data.picName.isNotEmpty ? data.picName : "-"}",
                        const Color(0xFF64748B),
                      ),
                      const SizedBox(height: 8),
                      // Badge Alamat (Gaya Maps)
                      _buildLocationBadge(),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // --- 3. STATUS & AKSI ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(isValidated, statusColor),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildIconButton(
                          Icons.edit_outlined,
                          Colors.blue,
                          onEdit,
                        ),
                        const SizedBox(width: 8),
                        _buildIconButton(
                          Icons.delete_outline_rounded,
                          Colors.red,
                          onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER: THUMBNAIL GAMBAR ---
  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 75,
        height: 75,
        color: const Color(0xFFF1F5F9),
        child: _getImageWidget(),
      ),
    );
  }

  Widget _getImageWidget() {
    if (data.fotoLahan.isEmpty || data.fotoLahan == "-") {
      return const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 28,
      );
    }

    // Mengarahkan ke endpoint image controller di backend Go
    String fullUrl = "$_imageBaseUrl${data.fotoLahan}";

    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) =>
              const Icon(Icons.broken_image_outlined, color: Colors.grey),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER: ROW INFO ---
  Widget _buildInfoRow(
    IconData icon,
    String label,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isBold ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER: LOCATION BADGE ---
  Widget _buildLocationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD0E7FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_rounded, size: 12, color: Colors.blue),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              data.alamatLahan,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF1565C0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: STATUS BADGE ---
  Widget _buildStatusBadge(bool isValid, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        isValid ? "VALID" : "PENDING",
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  // --- WIDGET HELPER: ICON BUTTON ---
  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LandDetailDialog(data: data),
    );
  }
}
