import 'package:flutter/material.dart';
import '../../../controller/add_land_controller.dart';
import '../common/custom_dropdown.dart';
import '../common/section_card.dart';

class PoliceInfoSection extends StatelessWidget {
  final AddLandController controller;

  const PoliceInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Informasi Kepolisian',
      icon: Icons.local_police_outlined,
      children: [
        CustomDropdown(
          label: 'Kepolisian Resor',
          hint: 'Pilih Kepolisian Resor',
          value: controller.selectedResor,
          items: controller.resorList,
          onChanged: controller.onResorChanged,
          prefixIcon: Icons.location_city_outlined,
        ),
        CustomDropdown(
          label: 'Kepolisian Sektor',
          hint: 'Pilih Kepolisian Sektor',
          value: controller.selectedSektor,
          items: controller.sektorList,
          onChanged: controller.onSektorChanged,
          prefixIcon: Icons.shield_outlined,
        ),
      ],
    );
  }
}