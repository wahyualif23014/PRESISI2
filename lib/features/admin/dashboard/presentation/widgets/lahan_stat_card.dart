import 'package:flutter/material.dart';
import '../../data/model/ringkasan_area_model.dart'; 

enum CardLayoutType { list, grid }

class LahanStatCard extends StatelessWidget {
  final RingkasanAreaModel data; 
  final Color backgroundColor;
  final CardLayoutType layoutType;

  const LahanStatCard({
    super.key,
    required this.data,
    required this.backgroundColor,
    this.layoutType = CardLayoutType.grid, // Default grid
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- 1. HEADER SECTION ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kiri: Label Data
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Data",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Total Keseluruhan",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              // Kanan: Angka Besar
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatNumber(data.totalValue), // <-- Menggunakan totalValue sesuai Model
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 5),
                    child: Text(
                      "HA",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- 2. BODY SECTION (List / Grid) ---
          layoutType == CardLayoutType.list
              ? _buildVerticalListLayout()
              : _buildGridLayout(context),

          const SizedBox(height: 24),

          // --- 3. FOOTER TITLE ---
          Text(
            data.title, 
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // --- Layout 1: Vertikal List (Detail - Kartu Biru) ---
  Widget _buildVerticalListLayout() {
    return Column(
      children: data.items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              _buildIcon(item.category), // <-- Mengirim Enum Category, bukan label String
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    // Label
                    Flexible(
                      child: Text(
                        "${item.label} : ",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Value
                    Text(
                      "${_formatNumber(item.value)} HA",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Layout 2: Grid Layout (Compact - Kartu Hijau/Merah) ---
  Widget _buildGridLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: data.items.map((item) {
            return Container(
              width: itemWidth,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(item.category), // <-- Mengirim Enum Category
                  const SizedBox(width: 8),
                  // Value Only
                  Flexible(
                    child: Text(
                      "${_formatNumber(item.value)} HA",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // --- Helper: Build Icon dengan Ring Oranye ---
  // SEKARANG MENERIMA ENUM (LandCategory) AGAR LEBIH KONSISTEN
  Widget _buildIcon(LandCategory category) {
    IconData iconData;

    switch (category) {
      case LandCategory.productive:
        iconData = Icons.settings_suggest_rounded;
        break;
      case LandCategory.forestry:
        iconData = Icons.park_rounded;
        break;
      case LandCategory.agriculture:
        iconData = Icons.agriculture_rounded;
        break;
      case LandCategory.religious:
        iconData = Icons.mosque_rounded;
        break;
      case LandCategory.other:
      default:
        iconData = Icons.circle;
        break;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFFA726),
          width: 2,
        ),
      ),
      child: Icon(
        iconData,
        size: 16,
        color: Colors.black87,
      ),
    );
  }

  // --- Helper: Format Angka ---
  String _formatNumber(double number) {
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(2);
  }
}