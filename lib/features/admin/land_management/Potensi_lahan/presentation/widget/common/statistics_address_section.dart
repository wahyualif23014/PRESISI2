import 'package:KETAHANANPANGAN/core/theme/app_colors.dart' show AppColors;
import 'package:flutter/material.dart';
import '../../../controller/add_land_controller.dart';
import '../common/custom_number_field.dart';
import '../common/custom_text_field.dart';
import '../common/section_card.dart';

class StatisticsAddressSection extends StatelessWidget {
  final AddLandController controller;
  final VoidCallback onMapTap;
  final VoidCallback onGpsTap;

  const StatisticsAddressSection({
    super.key,
    required this.controller,
    required this.onMapTap,
    required this.onGpsTap,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Statistik & Alamat',
      icon: Icons.analytics_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomNumberField(
                controller: controller.jmlPoktanController,
                label: 'Jml Poktan',
                hint: '0',
                icon: Icons.groups_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomNumberField(
                controller: controller.luasLahanController,
                label: 'Luas (HA)',
                hint: '0.00',
                icon: Icons.square_foot_outlined,
                isDecimal: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomNumberField(
                controller: controller.jmlPetaniController,
                label: 'Jml Petani',
                hint: '0',
                icon: Icons.people_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAddressField(),
        // Section ini akan muncul otomatis jika selectedLocation di controller tidak null
        if (controller.hasLocation) _buildLocationInfo(),
      ],
    );
  }

  Widget _buildAddressField() {
    return CustomTextField(
      controller: controller.alamatController,
      label: 'Alamat Lahan',
      hint: 'Pilih lokasi di peta atau ketik manual',
      prefixIcon: Icons.location_on_outlined,
      maxLines: 2,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Jika sedang loading GPS, tampilkan spinner kecil
          controller.isLoading 
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : IconButton(
              icon: const Icon(Icons.gps_fixed, color: AppColors.forestGreen),
              onPressed: onGpsTap,
              tooltip: 'Gunakan lokasi saat ini',
            ),
          IconButton(
            icon: const Icon(Icons.map_outlined, color: AppColors.forestGreen),
            onPressed: onMapTap,
            tooltip: 'Buka peta',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.forestGreen.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.forestGreen.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_searching, 
                size: 16, 
                color: AppColors.forestGreen.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  // Menampilkan data real-time dari controller
                  'Lat: ${controller.selectedLocation!.latitude.toStringAsFixed(6)}, '
                  'Lng: ${controller.selectedLocation!.longitude.toStringAsFixed(6)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.slateGrey.withOpacity(0.7),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              GestureDetector(
                onTap: controller.clearLocation,
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}