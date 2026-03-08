import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/providers/dashboard_provider.dart';

class DistributionCard extends StatefulWidget {
  final double chartSize;

  const DistributionCard({super.key, this.chartSize = 80});

  @override
  State<DistributionCard> createState() => _DistributionCardState();
}

class _DistributionCardState extends State<DistributionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    final wilayah = provider.wilayahDistribution;

    final int totalTitik =
        wilayah.fold(0, (sum, e) => sum + e.totalTitik);

    final double totalPotensi =
        wilayah.fold(0.0, (sum, e) => sum + e.totalLuasPotensi);

    final proportions = wilayah.map((e) {
      if (totalPotensi == 0) return 0.0;
      return e.totalLuasPotensi / totalPotensi;
    }).toList();

    final chartColors = [
      const Color(0xFF22C55E),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: provider.isWilayahLoading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "DISTRIBUSI WILAYAH",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),

                if (wilayah.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Tidak ada data wilayah",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "$totalTitik",
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return SizedBox(
                            width: widget.chartSize,
                            height: widget.chartSize,
                            child: CustomPaint(
                              painter: _AnimatedDonutPainter(
                                colors: chartColors,
                                proportions: proportions,
                                strokeWidth: 12,
                                progress: _animation.value,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}

class _AnimatedDonutPainter extends CustomPainter {
  final List<Color> colors;
  final List<double> proportions;
  final double strokeWidth;
  final double progress;

  _AnimatedDonutPainter({
    required this.colors,
    required this.proportions,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;

    final trackPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    for (int i = 0; i < proportions.length; i++) {
      final sweepAngle = 2 * pi * proportions[i];
      final animatedSweep = sweepAngle * progress;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, animatedSweep, false, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedDonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.proportions != proportions;
  }
}