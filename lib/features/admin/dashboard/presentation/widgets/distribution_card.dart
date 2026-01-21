import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/model/distribution_model.dart'; // Pastikan import Model benar

class DistributionCard extends StatelessWidget {
  // Ubah parameter menjadi Model
  final DistributionModel data; 
  final double chartSize; 

  const DistributionCard({
    Key? key,
    required this.data, // Menerima data model langsung
    this.chartSize = 75.0, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Ambil data helper dari model
    // Asumsi di DistributionModel sudah ada getter 'colors' dan 'proportions'
    // Jika belum ada, kita map manual di sini:
    final List<Color> chartColors = data.items.map((e) => e.color).toList();
    final List<double> proportions = data.items.map((e) => e.value).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // JUDUL DARI DATA
          Text(
            data.label, // <--- Pakai data.label
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. ANGKA TOTAL
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${data.total}", // <--- Pakai data.total
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),

              // 2. DONUT CHART
              SizedBox(
                width: chartSize,
                height: chartSize,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    colors: chartColors,
                    proportions: proportions,
                    strokeWidth: chartSize * 0.25, 
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Painter tetap sama, tidak perlu diubah
class _DonutChartPainter extends CustomPainter {
  final List<Color> colors;
  final List<double> proportions;
  final double strokeWidth;

  _DonutChartPainter({
    required this.colors, 
    required this.proportions,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2; 
    
    final rect = Rect.fromCircle(
      center: center, 
      radius: radius - (strokeWidth / 2)
    );
    
    double startAngle = -pi / 2;

    for (int i = 0; i < proportions.length; i++) {
      final sweepAngle = 2 * pi * proportions[i];
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      
      startAngle += sweepAngle; 
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}