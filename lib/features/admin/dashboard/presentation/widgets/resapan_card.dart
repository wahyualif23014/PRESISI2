import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/model/resapan_model.dart';

class ResapanCard extends StatefulWidget {
  final ResapanModel data;
  final List<Color> colors = const [
    Color(0xFF8B5CF6), Color(0xFF3B82F6), Color(0xFFF59E0B),
    Color(0xFF10B981), Color(0xFFEF4444), Color(0xFF6366F1),
  ];

  const ResapanCard({super.key, required this.data});

  @override
  State<ResapanCard> createState() => _ResapanCardState();
}

class _ResapanCardState extends State<ResapanCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart);
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
        boxShadow: [BoxShadow(color: const Color(0xFF64748B).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Biar gak makan tempat berlebih
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          
          // PIE CHART DENGAN FIXED HEIGHT
          // Image of a data pie chart section in a mobile dashboard
          SizedBox(
            height: 200, // Tinggi harus didefinisikan
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                          touchedIndex = -1; return;
                        }
                        touchedIndex = response.touchedSection!.touchedSectionIndex;
                      });
                    }),
                    sectionsSpace: 4,
                    centerSpaceRadius: 55,
                    startDegreeOffset: -90,
                    sections: _buildPieSections(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("TOTAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                      _AnimatedTextValue(value: widget.data.total, animation: _animation),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          _buildLegendList(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    return widget.data.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;
      final double radius = isTouched ? 35 : 28;

      return PieChartSectionData(
        color: widget.colors[index % widget.colors.length],
        value: item.value,
        title: '', 
        radius: radius * _animation.value,
        showTitle: false,
      );
    }).toList();
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("RESAPAN LAHAN", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 1.0)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
          child: Text("Tahun ${widget.data.year}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
        ),
      ],
    );
  }

  Widget _buildLegendList() {
    return Column(
      children: List.generate(widget.data.items.length, (index) {
        final item = widget.data.items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: widget.colors[index % widget.colors.length], shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(child: Text(item.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF475569)))),
              Text("${item.value.toStringAsFixed(1)} HA", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }),
    );
  }
}

// Sub-widget untuk animasi angka total di tengah pie
class _AnimatedTextValue extends StatelessWidget {
  final double value;
  final Animation<double> animation;

  const _AnimatedTextValue({required this.value, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Text(
          (value * animation.value).toStringAsFixed(0),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        );
      },
    );
  }
}