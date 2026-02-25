import 'dart:math';
import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/distribution_model.dart'; 

class DistributionCard extends StatefulWidget {
  final DistributionModel data;
  final double chartSize;

  const DistributionCard({
    super.key,
    required this.data,
    this.chartSize = 80.0, // Sedikit diperbesar agar lebih jelas
  });

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
    // Setup Animasi Durasi 1.5 Detik
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Menggunakan Curve agar animasi tidak kaku (mulai cepat, melambat di akhir)
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // Jalankan animasi saat widget dibangun
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ekstrak data untuk cleaner code
    final List<Color> chartColors = widget.data.items.map((e) => e.color).toList();
    final List<double> proportions = widget.data.items.map((e) => e.value).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Shadow yang lebih soft dan modern
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. HEADER (Label)
          Text(
            widget.data.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600], // Warna abu-abu agar tidak terlalu dominan
              letterSpacing: 0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // 2. CONTENT (Angka & Chart)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bagian Kiri: Angka Total
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${widget.data.total}",
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800, // Extra Bold
                      height: 1.0,
                      color: Color(0xFF1E293B), // Slate 800
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Bagian Kanan: Animated Donut Chart
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
                        strokeWidth: 12.0, // Ketebalan donut
                        progress: _animation.value, // Nilai animasi 0.0 -> 1.0
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

// --- PAINTER CLASS (Logic Menggambar Chart) ---

class _AnimatedDonutPainter extends CustomPainter {
  final List<Color> colors;
  final List<double> proportions;
  final double strokeWidth;
  final double progress; // Parameter untuk animasi

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

    // Putar chart -90 derajat agar mulai dari jam 12 (atas)
    double startAngle = -pi / 2;

    // Background Circle (Abu-abu tipis sebagai track/dasar)
    final trackPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Menggambar Arc Berdasarkan Data
    for (int i = 0; i < proportions.length; i++) {
      // Hitung sudut penuh untuk item ini
      final double sweepAngle = 2 * pi * proportions[i];
      
      // Hitung sudut yang sudah di-animasi (dikalikan progress)
      // Ini membuat efek "memutar" atau "mengisi" lingkaran
      final double animatedSweep = sweepAngle * progress;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round; // Ujung bulat supaya lebih halus

      // Gambar Arc
      if (progress > 0) {
        canvas.drawArc(rect, startAngle, animatedSweep, false, paint);
      }

      // Update posisi start untuk item berikutnya (gunakan sudut penuh agar posisi konsisten)
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedDonutPainter oldDelegate) {
    // Repaint jika progress animasi berubah
    return oldDelegate.progress != progress ||
           oldDelegate.proportions != proportions;
  }
}