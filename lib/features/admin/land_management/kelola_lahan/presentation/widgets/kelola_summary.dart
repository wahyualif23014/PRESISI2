import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';

class LandManagementSummary extends StatelessWidget {
  final LandManagementSummaryModel? data;
  final bool isLoading;

  const LandManagementSummary({
    super.key,
    required this.data,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    if (data == null) return const SizedBox();

    return Column(
      children: [
        // Baris 1
        Row(
          children: [
            Expanded(child: _buildCard("Total Potensi Lahan ${data!.totalPotensiLahan} Ha")),
            const SizedBox(width: 8),
            Expanded(child: _buildCard("Total Tanam Lahan ${data!.totalTanamLahan} Ha")),
          ],
        ),
        const SizedBox(height: 8),
        // Baris 2
        Row(
          children: [
            Expanded(child: _buildCard("Total Panen Lahan ${data!.totalPanenLahanHa} Ha (${data!.totalPanenLahanTon} Ton)")),
            const SizedBox(width: 8),
            Expanded(child: _buildCard("Total Serapan ${data!.totalSerapanTon} Ton")),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.black, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}