import 'package:flutter/material.dart';
import '../../../controller/add_land_controller.dart';
import '../common/custom_dropdown.dart';
import '../common/section_card.dart';

class LandDetailSection extends StatelessWidget {
  final AddLandController controller;

  const LandDetailSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Detail Lahan',
      icon: Icons.landscape_outlined,
      children: [
        // Input Luas Lahan (Double/Decimal)
        TextFormField(
          controller: controller.luasLahanController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Luas Lahan (Ha)',
            hintText: 'Contoh: 1.5',
            prefixIcon: Icon(Icons.square_foot_outlined),
          ),
          validator: (val) {
            if (val == null || val.isEmpty) return 'Wajib diisi';
            if (double.tryParse(val) == null) return 'Format angka tidak valid';
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Dropdown Jenis Lahan (ID 1-9)
        CustomDropdown(
          label: 'Jenis Lahan',
          hint: 'Pilih Jenis Lahan',
          value: controller.selectedJenisLahan,
          items: controller.jenisLahanList,
          onChanged: controller.onJenisLahanChanged,
          prefixIcon: Icons.category_outlined,
        ),
        const SizedBox(height: 16),

        // Dropdown Komoditi (ID Komoditi)
        CustomDropdown(
          label: 'Komoditi',
          hint: 'Pilih Komoditi',
          value: controller.selectedKomoditi,
          items: controller.komoditiList,
          onChanged: controller.onKomoditiChanged,
          prefixIcon: Icons.agriculture_outlined,
        ),
        const SizedBox(height: 16),

        // Dropdown ENUM: Mapping Label ke ID '1','2','3'
        CustomDropdown(
          label: 'Status Pemanfaatan Lahan',
          hint: 'Pilih Status',
          value: controller.selectedKetLainId == "1" 
              ? "PRODUKTIF" 
              : controller.selectedKetLainId == "2" 
                  ? "NON-PRODUKTIF" 
                  : "LAHAN TIDUR",
          items: controller.ketLainOptions,
          onChanged: (val) => controller.onKetLainChanged(val!),
          prefixIcon: Icons.assignment_turned_in_outlined,
        ),
        const SizedBox(height: 16),

        // Input Keterangan Deskripsi (Longtext di DB)
        TextFormField(
          controller: controller.picKeteranganController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Keterangan/Deskripsi Lahan',
            hintText: 'Tuliskan detail kondisi lahan...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}