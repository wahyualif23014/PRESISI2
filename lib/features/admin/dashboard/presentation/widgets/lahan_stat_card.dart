import 'package:flutter/material.dart';
import '../../../dashboard/data/model/lahan_group_model.dart';
import '../../data/model/dasboard_model.dart'; // Sesuaikan path model

enum CardLayoutType { list, grid }

class LahanStatCard extends StatelessWidget {
  final String title;
  final LahanGroup data;
  final Color backgroundColor;
  final CardLayoutType layoutType; 

  const LahanStatCard({
    super.key,
    required this.title,
    required this.data,
    required this.backgroundColor,
    this.layoutType = CardLayoutType.grid, // Default Grid (kecil)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER SECTION ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Data",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Total Keseluruhan",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatNumber(data.total),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28, // Ukuran font besar
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      "HA",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- BODY SECTION (List atau Grid) ---
          if (layoutType == CardLayoutType.list)
            _buildVerticalListLayout()
          else
            _buildGridLayout(),

          const SizedBox(height: 20),
          
          // --- FOOTER TITLE ---
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Layout 1: Vertikal List (Seperti Kartu Kuning)
  Widget _buildVerticalListLayout() {
    return Column(
      children: data.details.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white, // Transparan putih
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              // Lingkaran Icon
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Label
              Expanded(
                child: Text(
                  "${item.label} :",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
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
        );
      }).toList(),
    );
  }

  // Layout 2: Grid Chips (Seperti Kartu Orange & Ungu)
  Widget _buildGridLayout() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: data.details.map((item) {
        // Karena pakai Wrap, kita batasi lebar item agar jadi 2 kolom (approx)
        return LayoutBuilder(
          builder: (context, constraints) {
             return Container(
              width: (constraints.maxWidth > 300) ? 140 : 120, // Lebar fixed chip
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${_formatNumber(item.value)} HA",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ), 
                ],
              ),
            );
          }
        );
      }).toList(),
    );
  }

  String _formatNumber(double number) {
    // Hilangkan .0 jika bulat
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(2);
  }
}