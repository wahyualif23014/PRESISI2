import 'dart:io';
import 'dart:typed_data';
import 'package:KETAHANANPANGAN/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? imageFile;
  final Uint8List? imageBytes;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onClear;

  const ImagePickerWidget({
    super.key,
    this.imageFile,
    this.imageBytes,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.image_outlined, color: AppColors.forestGreen, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Foto Lahan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.slateGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (imageFile != null)
          _buildImagePreview(
            child: Image.file(
              imageFile!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else if (imageBytes != null)
          _buildImagePreview(
            child: Image.memory(
              imageBytes!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          _buildEmptyState(context), // Tambahkan context di sini
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImagePreview({required Widget child}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: child,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return InkWell(
      onTap: () => _showImageSourceDialog(context), // Panggil dialog
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.warmBeige.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.forestGreen.withOpacity(0.2),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 32,
                color: AppColors.forestGreen,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tambahkan Foto',
              style: TextStyle(
                color: AppColors.forestGreen,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ketuk untuk memilih sumber gambar',
              style: TextStyle(
                color: AppColors.slateGrey.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.forestGreen),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                onCameraTap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.forestGreen),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                onGalleryTap();
              },
            ),
          ],
        ),
      ),
    );
  }
}