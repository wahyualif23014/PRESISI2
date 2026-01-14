import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HarvestChartCard extends StatefulWidget {
  final double totalPanen; 
  
  const HarvestChartCard({super.key, required this.totalPanen});

  @override
  State<HarvestChartCard> createState() => _HarvestChartCardState();
}

class _HarvestChartCardState extends State<HarvestChartCard> {
  bool showTotal = true;
  bool showJagung = false; // Default off agar tidak terlalu ramai
  bool showUbi = false;

 
  final Color totalColor = const Color(0xFF10B981); // Emerald
  final Color jagungColor = const Color(0xFFF59E0B); // Amber
  final Color ubiColor = const Color(0xFF8B5CF6); // Violet

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Konsisten
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
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ANALISIS HASIL PANEN",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatCurrency(widget.totalPanen),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          fontSize: 24,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4, left: 4),
                        child: Text(
                          "Ton",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Filter Button (Visual)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Icon(Icons.tune_rounded, size: 20, color: Colors.grey.shade600),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCustomChip("Total Hasil", totalColor, showTotal, (v) => setState(() => showTotal = v)),
                const SizedBox(width: 12),
                _buildCustomChip("Jagung", jagungColor, showJagung, (v) => setState(() => showJagung = v)),
                const SizedBox(width: 12),
                _buildCustomChip("Ubi Ungu", ubiColor, showUbi, (v) => setState(() => showUbi = v)),
              ],
            ),
          ),

          const SizedBox(height: 32),
          
          // Chart Area
          Expanded(
            child: LineChart(
              mainData(),
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    // Format simpel: 12500.0 -> 12,500
    return value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Widget _buildCustomChip(String label, Color color, bool isSelected, Function(bool) onSelected) {
    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          boxShadow: isSelected 
            ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] 
            : [],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData mainData() {
    List<LineChartBarData> visibleLines = [];
    if (showTotal) visibleLines.add(_lineTotal());
    if (showJagung) visibleLines.add(_lineJagung());
    if (showUbi) visibleLines.add(_lineUbi());

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2, 
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 1, // Tampilkan setiap bulan
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 40,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0, maxX: 11, 
      minY: 0, maxY: 8, 
      lineBarsData: visibleLines,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.white,
          tooltipBorder: BorderSide(color: Colors.grey.shade200),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
               return LineTooltipItem(
                "${spot.y}k Ton",
                const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  // --- CHART LINES ---
  
  LineChartBarData _lineTotal() {
    return LineChartBarData(
      spots: const [
        FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5), 
        FlSpot(4, 4.5), FlSpot(5, 6), FlSpot(6, 5.5), FlSpot(7, 6.5), 
        FlSpot(8, 7), FlSpot(9, 6), FlSpot(10, 5), FlSpot(11, 5.5),
      ],
      isCurved: true,
      color: totalColor,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [totalColor.withOpacity(0.2), totalColor.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  LineChartBarData _lineJagung() => _baseLine(jagungColor, const [
    FlSpot(0, 1), FlSpot(1, 1.5), FlSpot(2, 1.2), FlSpot(3, 2), 
    FlSpot(4, 1.8), FlSpot(5, 2.5), FlSpot(6, 2), FlSpot(7, 2.2), 
    FlSpot(8, 2.5), FlSpot(9, 2), FlSpot(10, 1.5), FlSpot(11, 1.8),
  ]);

  LineChartBarData _lineUbi() => _baseLine(ubiColor, const [
    FlSpot(0, 0.5), FlSpot(1, 0.8), FlSpot(2, 0.6), FlSpot(3, 1), 
    FlSpot(4, 0.8), FlSpot(5, 1.2), FlSpot(6, 1), FlSpot(7, 1.5), 
    FlSpot(8, 1.2), FlSpot(9, 1), FlSpot(10, 0.8), FlSpot(11, 0.5),
  ]);

  LineChartBarData _baseLine(Color color, List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  // --- AXIS WIDGETS ---
  
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF94A3B8));
    // Tampilkan hanya bulan genap agar tidak penuh
    if (value % 2 != 0) return const SizedBox.shrink();
    
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN', 'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'];
    return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: Text(months[value.toInt()], style: style));
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF94A3B8));
    return Text('${value.toInt()}k', style: style, textAlign: TextAlign.left);
  }
}