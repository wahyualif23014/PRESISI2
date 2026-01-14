import 'dart:math';
import 'package:flutter/material.dart';

class DistributionCard extends StatelessWidget {
  final String title;
  final int totalValue;
  final List<Color> chartColors;
  final List<double> proportions;
  
  // Tambahan: Ukuran chart agar konsisten (Default 70x70)
  final double chartSize; 

  const DistributionCard({
    Key? key,
    required this.title,
    required this.totalValue,
    required this.chartColors,
    required this.proportions,
    this.chartSize = 75.0, // Ukuran default yang pas dengan font 48
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

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
          // JUDUL
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // ROW KONTEN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center, // Sejajarkan tengah secara vertikal
            children: [
              // 1. ANGKA TOTAL
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "$totalValue",
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

              // 2. DONUT CHART (FIXED SQUARE SIZE)
              // Menggunakan SizedBox dengan width & height yang SAMA
              SizedBox(
                width: chartSize,
                height: chartSize,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    colors: chartColors,
                    proportions: proportions,
                    // Opsional: atur ketebalan stroke relatif terhadap size
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

// --- Custom Painter ---
class _DonutChartPainter extends CustomPainter {
  final List<Color> colors;
  final List<double> proportions;
  final double strokeWidth; // Tambahkan parameter stroke width

  _DonutChartPainter({
    required this.colors, 
    required this.proportions,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Radius adalah setengah dari lebar/tinggi
    final radius = size.width / 2; 
    
    // Rect untuk area gambar
    final rect = Rect.fromCircle(
      center: center, 
      radius: radius - (strokeWidth / 2) // Kurangi radius dengan setengah stroke agar tidak terpotong
    );
    
    double startAngle = -pi / 2; // Mulai jam 12

    for (int i = 0; i < proportions.length; i++) {
      final sweepAngle = 2 * pi * proportions[i];
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt; // Ujung rata (sesuai gambar referensi)

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      
      startAngle += sweepAngle; 
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}