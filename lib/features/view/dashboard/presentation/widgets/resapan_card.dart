import 'package:flutter/material.dart';
import '../../data/model/resapan_model.dart'; 

class ResapanCard extends StatefulWidget {
  final ResapanModel data;
  
  final List<Color> colors = const [
    Color(0xFF8B5CF6), // Violet
    Color(0xFF3B82F6), // Blue
    Color(0xFFF59E0B), // Amber
  ];

  const ResapanCard({super.key, required this.data});

  @override
  State<ResapanCard> createState() => _ResapanCardState();
}

class _ResapanCardState extends State<ResapanCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Setup Controller Durasi 1.2 Detik
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // Jalankan animasi saat widget muncul
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          _CardHeader(year: widget.data.year),
          
          const SizedBox(height: 8),

          // 2. ANGKA TOTAL (ANIMATED COUNTING)
          _AnimatedTotalValue(
            total: widget.data.total.toDouble(),
            animation: _animation,
          ),
          
          const SizedBox(height: 24),

          // 3. BAR CHART (GROWING ANIMATION)
          _AnimatedStackedBarChart(
            items: widget.data.items,
            colors: widget.colors,
            animation: _animation,
          ),
          
          const SizedBox(height: 24),

          // 4. LEGEND LIST (STAGGERED ANIMATION)
          Column(
            children: List.generate(widget.data.items.length, (index) {
              final item = widget.data.items[index];
              final color = widget.colors[index % widget.colors.length];
              final isLast = index == widget.data.items.length - 1;

              // Staggered delay: Item muncul berurutan
              // index * 0.2 artinya item ke-2 muncul saat animasi progress 20%, dst.
              final startInterval = (index * 0.1).clamp(0.0, 0.8);
              final endInterval = (startInterval + 0.4).clamp(0.0, 1.0);

              final itemAnimation = CurvedAnimation(
                parent: _controller,
                curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
              );

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: _AnimatedLegendItem(
                  label: item.label,
                  value: item.value.toDouble(),
                  color: color,
                  animation: itemAnimation,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ANIMATED SUB-WIDGETS
// =============================================================================

class _CardHeader extends StatelessWidget {
  final String year;

  const _CardHeader({required this.year});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "TOTAL RESAPAN",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 1.0,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Tahun $year",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedTotalValue extends StatelessWidget {
  final double total;
  final Animation<double> animation;

  const _AnimatedTotalValue({
    required this.total,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Menghitung nilai saat ini berdasarkan progress animasi (0 -> total)
        final currentValue = total * animation.value;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatNumber(currentValue),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                height: 1.0,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                "HA",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatNumber(double number) {
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(2);
  }
}

class _AnimatedStackedBarChart extends StatelessWidget {
  final List<ResapanItem> items;
  final List<Color> colors;
  final Animation<double> animation;

  const _AnimatedStackedBarChart({
    required this.items,
    required this.colors,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final totalValue = items.fold<double>(0.0, (sum, item) => sum + item.value.toDouble());
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return SizedBox(
            height: 12,
            child: Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                
                // Menghitung flex normal
                final originalFlex = totalValue > 0 
                    ? (item.value.toDouble() / totalValue * 1000).toInt() // Skala 1000 utk presisi
                    : 1;

                // Animasi Lebar: 
                // Kita gunakan Container width di dalam Expanded atau Flex yang dinamis.
                // Namun, cara termudah di Row adalah memanipulasi flex atau width content.
                // Disini kita gunakan Align + FractionallySizedBox di dalam Expanded statis 
                // ATAU yang lebih simpel: Container width dikalikan animasi (tapi butuh LayoutBuilder).
                
                // Pendekatan Simpel: Flex tetap, tapi isi container di-scale
                
                if (item.value <= 0) return const SizedBox.shrink();

                return Expanded(
                  flex: originalFlex,
                  child: Align(
                    alignment: Alignment.centerLeft, // Tumbuh dari kiri
                    child: FractionallySizedBox(
                      widthFactor: animation.value, // Lebar 0.0 -> 1.0 (Penuh sesuai flex)
                      heightFactor: 1.0,
                      child: Container(
                        color: colors[index % colors.length],
                        margin: EdgeInsets.only(right: index == items.length - 1 ? 0 : 2),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedLegendItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final Animation<double> animation;

  const _AnimatedLegendItem({
    required this.label,
    required this.value,
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation, // Efek Fade In
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5), // Mulai sedikit dari bawah
          end: Offset.zero,
        ).animate(animation),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF475569),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            Text(
              "${_formatNumber(value)} HA",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(2);
  }
}