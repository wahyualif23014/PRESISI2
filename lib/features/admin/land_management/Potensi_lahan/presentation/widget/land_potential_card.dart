import 'package:flutter/material.dart';
import '../../data/model/land_potential_model.dart';
import 'land_detail_dialog.dart';

class LandPotentialCard extends StatelessWidget {
  final LandPotentialModel data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh; // Tambahkan refresh callback

  const LandPotentialCard({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh, // Masukkan ke constructor
  });

  // Sesuaikan Base URL dengan route /uploads/ yang terdaftar di backend
  static const String _imageBaseUrl = "http://192.168.100.195:8080/uploads/";

  @override
  Widget build(BuildContext context) {
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
                _buildThumbnail(),
                const SizedBox(width: 12),
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
                      _buildLocationBadge(),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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

    // Pastikan data.fotoLahan hanya berisi nama file (misal: image_123.jpg)
    String fileName = data.fotoLahan;
    if (fileName.contains(',')) {
      // Jika data berupa Base64, gunakan widget Image.memory di detail dialog saja
      // Untuk Card, kita asumsikan mengambil via URL path
      return const Icon(Icons.image, color: Colors.grey);
    }

    String fullUrl = "$_imageBaseUrl${Uri.encodeComponent(fileName)}";

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

  void _showDetail(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => LandDetailDialog(data: data),
    );
    // Jika ada aksi validasi di dalam dialog, refresh halaman utama
    if (result == true) {
      onRefresh();
    }
  }
}
