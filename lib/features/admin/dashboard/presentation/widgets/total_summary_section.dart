import 'package:flutter/material.dart';
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
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              "Ringkasan Data Potensi",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Expanded(child: _buildCompactCard(items[i])),
                if (i < items.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),

          // Logika untuk menampilkan card persentase validasi jika ada
          _buildValidationInfo(items),
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
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      _formatNumber(item.value),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
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
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildValidationInfo(List<SummaryItemModel> items) {
    // Cari item yang memiliki data percentage (biasanya data Validasi)
    final validationItem = items.cast<SummaryItemModel?>().firstWhere(
      (item) => item?.percentage != null,
      orElse: () => null,
    );

    if (validationItem == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF475569), // Slate 600
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Colors.white, fontSize: 13),
          children: [
            const TextSpan(text: "TOTAL "),
            TextSpan(
              text: "${validationItem.percentage}%",
              style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: " DATA BELUM DIVALIDASI, DARI "),
            TextSpan(
              text: "${_formatNumber(validationItem.value)} ${validationItem.unit}",
              style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: " LUAS POTENSI LAHAN"),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(SummaryType type) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case SummaryType.potensi:
        iconData = Icons.info_outline_rounded;
        iconColor = const Color(0xFF0D47A1);
        bgColor = const Color(0xFFE3F2FD);
        break;
      case SummaryType.lokasi:
        iconData = Icons.location_on_rounded;
        iconColor = const Color(0xFF1565C0);
        bgColor = const Color(0xFFE3F2FD);
        break;
      case SummaryType.success:
        iconData = Icons.verified_rounded;
        iconColor = const Color(0xFF16A34A);
        bgColor = const Color(0xFFDCFCE7);
        break;
      default:
        iconData = Icons.analytics_rounded;
        iconColor = const Color(0xFF64748B);
        bgColor = const Color(0xFFF1F5F9);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(iconData, size: 24, color: iconColor),
    );
  }

  String _formatNumber(double number) {
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(2);
  }
}