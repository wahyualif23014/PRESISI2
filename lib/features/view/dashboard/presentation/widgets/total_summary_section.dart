import 'package:flutter/material.dart';
// Pastikan import model sudah benar
import '../../data/model/summary_item_model.dart'; 

class TotalSummarySection extends StatelessWidget {
  final List<SummaryItemModel> items;

  const TotalSummarySection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        // Shadow halus untuk kontainer utama
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section (Opsional: Judul Ringkasan)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              "Ringkasan Panen",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B), // Slate 800
              ),
            ),
          ),
          
          // Grid Items
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Expanded(child: _buildCompactCard(items[i])),
                if (i < items.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard(SummaryItemModel item) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC), // Slate 50 (Background Card Sedikit Abu)
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)), // Slate 200
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(item.type),
              const SizedBox(height: 12),

              // Value & Unit
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      _formatNumber(item.value),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800, // Extra Bold
                        color: Color(0xFF0F172A), // Slate 900 (Hitam Pekat)
                        height: 1.0,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    item.unit,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B), // Slate 500 (Abu Medium)
                      height: 1.5, 
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        
        // Label di bawah card
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569), // Slate 600
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildIcon(SummaryType type) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case SummaryType.success:
        iconData = Icons.verified_rounded; // Ganti icon agar lebih representatif
        iconColor = const Color(0xFF16A34A); // Green 600
        bgColor = const Color(0xFFDCFCE7); // Green 100
        break;
      case SummaryType.failed:
        iconData = Icons.gpp_bad_rounded;
        iconColor = const Color(0xFFDC2626); // Red 600
        bgColor = const Color(0xFFFEE2E2); // Red 100
        break;
      case SummaryType.plant:
        iconData = Icons.local_florist_rounded;
        iconColor = const Color(0xFF059669); // Emerald 600
        bgColor = const Color(0xFFD1FAE5); // Emerald 100
        break;
      case SummaryType.process:
        iconData = Icons.pending_actions_rounded;
        iconColor = const Color(0xFFD97706); // Amber 600
        bgColor = const Color(0xFFFEF3C7); // Amber 100
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor, 
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 24, color: iconColor),
    );
  }

  String _formatNumber(double number) {
    // Format ribuan jika perlu (opsional)
    if (number % 1 == 0) {
      return number.toInt().toString();
    }
    return number.toString();
  }
}