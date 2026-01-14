import 'package:flutter/material.dart';
import '../../data/model/summary_item_model.dart';

class TotalSummarySection extends StatelessWidget {
  final List<SummaryItem> items;

  const TotalSummarySection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // Padding container diperkecil
      decoration: BoxDecoration(
        color: Colors.white, // Background abu-kebiruan
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Loop items dan bungkus dengan Expanded agar lebarnya rata
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

  Widget _buildCompactCard(SummaryItem item) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black12,
            ), 
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(item.type),
              const SizedBox(height: 8),

              // Angka & Unit
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      _formatNumber(item.value),
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    item.unit,
                    style: const TextStyle(
                      fontSize: 10, // Unit kecil
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Label di bawah card
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Helper Icon (Ukuran diperkecil ke 32)
  Widget _buildIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'success':
        iconData = Icons.agriculture;
        color = const Color(0xFFEAB308);
        break;
      case 'failed':
        iconData = Icons.warning_amber_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case 'plant':
        iconData = Icons.eco;
        color = const Color(0xFF4ADE80);
        break;
      case 'process':
        iconData = Icons.hourglass_bottom_rounded;
        color = const Color(0xFF8D6E63);
        break;
      default:
        iconData = Icons.help_outline;
        color = Colors.grey;
    }

    return Icon(iconData, size: 28, color: color); // Ukuran icon 32
  }

  String _formatNumber(double number) {
    return number % 1 == 0 ? number.toInt().toString() : number.toString();
  }
}
