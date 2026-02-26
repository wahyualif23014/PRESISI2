import 'package:flutter/material.dart';
import '../../../controller/add_land_controller.dart';
import '../common/custom_text_field.dart';
import '../common/section_card.dart';

class ContactInfoSection extends StatelessWidget {
  final AddLandController controller;

  const ContactInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Informasi Petugas & Kontak',
      icon: Icons.person_outline,
      children: [
        CustomTextField(
          controller: controller.policeNameController,
          label: 'Polisi Penggerak',
          hint: 'Nama Anggota',
          prefixIcon: Icons.badge_outlined,
        ),
        CustomTextField(
          controller: controller.policePhoneController,
          label: 'Kontak Polisi',
          hint: 'No. HP',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        CustomTextField(
          controller: controller.picNameController,
          label: 'Penanggung Jawab',
          hint: 'Nama PIC',
          prefixIcon: Icons.person_outline,
        ),
        CustomTextField(
          controller: controller.picPhoneController,
          label: 'Kontak PIC',
          hint: 'No. HP PIC',
          prefixIcon: Icons.phone_android_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}