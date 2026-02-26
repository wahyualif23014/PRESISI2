import 'package:flutter/material.dart';
import '../../../controller/add_land_controller.dart';
import '../common/custom_text_field.dart';
import '../common/image_picker_widget.dart';
import '../common/section_card.dart';

class DocumentationSection extends StatelessWidget {
  final AddLandController controller;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const DocumentationSection({
    super.key,
    required this.controller,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Dokumentasi',
      icon: Icons.camera_alt_outlined,
      children: [
        ImagePickerWidget(
          imageFile: controller.selectedImageFile,
          imageBytes: controller.imageBytes,
          onCameraTap: onCameraTap,
          onGalleryTap: onGalleryTap,
          onClear: controller.clearImage,
        ),
        CustomTextField(
          controller: controller.ketLainController,
          label: 'Keterangan Lain',
          hint: 'Info tambahan',
          prefixIcon: Icons.notes_outlined,
          maxLines: 2,
        ),
      ],
    );
  }
}