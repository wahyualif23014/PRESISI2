import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/dashboard/data/model/harvest_model.dart';

// Import model yang sudah dibuat sebelumnya

class GrafikChartCard extends StatefulWidget {
  final HarvestModel data; 

  const GrafikChartCard({super.key, required this.data});

  @override
  State<GrafikChartCard> createState() => _GrafikChartCardState();
}

class _GrafikChartCardState extends State<GrafikChartCard> {


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
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
          // --- HEADER SECTION (Dinamis dari Model) ---
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
                        _formatCurrency(widget.data.totalPanenCurrent),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          fontSize: 24,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 4),
                        child: Text(
                          widget.data.unit, // "Ton" dari Model
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Filter Button (Visual Only)
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

          // --- FILTER CHIPS (Generated from List Categories) ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.data.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildCustomChip(
                    category.label,
                    category.color,
                    category.isVisible,
                    (value) {
                      setState(() {
                        // Toggle visibility
                        category.isVisible = value;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 32),

          // --- CHART AREA ---
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

  // --- LOGIC CHART ---

  LineChartData mainData() {
    // Generate Lines hanya untuk kategori yang isVisible == true
    List<LineChartBarData> visibleLines = widget.data.categories
        .where((cat) => cat.isVisible)
        .map((cat) => _createLineData(cat))
        .toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 2,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey.shade100, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 1,
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
      minY: 0, maxY: 8, // Bisa dibuat dinamis berdasarkan max value data
      lineBarsData: visibleLines,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.white,
          tooltipBorder: BorderSide(color: Colors.grey.shade200),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                "${spot.y}k ${widget.data.unit}",
                const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  // Helper untuk mengubah Model ke FL Chart LineBarData
  LineChartBarData _createLineData(HarvestCategoryData category) {
    final spots = category.dataPoints
        .map((point) => FlSpot(point.monthIndex.toDouble(), point.value))
        .toList();

    // Khusus untuk ID 'total', kita beri style Gradient seperti request UI Anda
    if (category.id == 'total') {
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: category.color,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              category.color.withOpacity(0.2),
              category.color.withOpacity(0.0)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    } 
    
    // Style Standard untuk Jagung, Ubi, dll
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: category.color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  // --- WIDGET BUILDERS & FORMATTERS ---

  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Widget _buildCustomChip(
      String label, Color color, bool isSelected, Function(bool) onSelected) {
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
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
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

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF94A3B8));
    if (value % 2 != 0) return const SizedBox.shrink();

    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN',
      'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'
    ];
    // Safety check index
    if (value.toInt() >= 0 && value.toInt() < months.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 10,
        child: Text(months[value.toInt()], style: style),
      );
    }
    return const SizedBox.shrink();
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF94A3B8));
    return Text('${value.toInt()}k', style: style, textAlign: TextAlign.left);
  }
}