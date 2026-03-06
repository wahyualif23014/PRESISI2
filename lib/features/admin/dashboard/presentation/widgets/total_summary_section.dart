import 'package:flutter/material.dart';
import '../../data/model/summary_item_model.dart'; 

class TotalSummarySection extends StatelessWidget {
  final List<SummaryItemModel> items;

  const TotalSummarySection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ringkasan Data Potensi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 20),
          
          LayoutBuilder(
            builder: (context, constraints) {
              // Menghitung jumlah kolom: 4 jika tablet, 2 jika mobile sempit
              int crossAxisCount = constraints.maxWidth > 400 ? 4 : 2;
              double itemWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 12)) / crossAxisCount;

              return Wrap(
                spacing: 12,
                runSpacing: 16,
                children: items.map((item) => SizedBox(
                  width: itemWidth,
                  child: _buildCompactCard(item),
                )).toList(),
              );
            },
          ),

          _buildValidationInfo(items),
        ],
      ),
    );
  }

  Widget _buildCompactCard(SummaryItemModel item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildIcon(item.type),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatNumber(item.value),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.0),
                    ),
                    const SizedBox(width: 2),
                    Text(item.unit, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569), height: 1.1),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildValidationInfo(List<SummaryItemModel> items) {
    final validationItem = items.cast<SummaryItemModel?>().firstWhere(
      (item) => item?.percentage != null, orElse: () => null);

    if (validationItem == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF334155), Color(0xFF1E293B)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.5),
          children: [
            const TextSpan(text: "TOTAL "),
            TextSpan(text: "${validationItem.percentage}%", style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.w900)),
            const TextSpan(text: " DATA BELUM DIVALIDASI, DARI "),
            TextSpan(text: "${_formatNumber(validationItem.value)} ${validationItem.unit}", style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.w900)),
            const TextSpan(text: " LUAS POTENSI LAHAN"),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(SummaryType type) {
    IconData icon;
    Color color;
    switch (type) {
      case SummaryType.potensi: icon = Icons.analytics_outlined; color = Colors.blue; break;
      case SummaryType.lokasi: icon = Icons.location_on_outlined; color = Colors.orange; break;
      case SummaryType.success: icon = Icons.check_circle_outline; color = Colors.green; break;
      default: icon = Icons.help_outline; color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: color),
    );
  }

  String _formatNumber(double number) => number % 1 == 0 ? number.toInt().toString() : number.toStringAsFixed(2);
}