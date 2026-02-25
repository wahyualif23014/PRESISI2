import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/harvest_model.dart';

class GrafikChartCard extends StatefulWidget {
  final HarvestModel data;

  const GrafikChartCard({super.key, required this.data});

  @override
  State<GrafikChartCard> createState() => _GrafikChartCardState();
}

class _GrafikChartCardState extends State<GrafikChartCard> {
  // Logic untuk memunculkan Filter Modal di tengah layar
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => const _FilterAnalysisDialog(),
    );
  }

  // Logic untuk update state visibility chart
  void _toggleCategoryVisibility(HarvestCategoryData category, bool isVisible) {
    setState(() {
      category.isVisible = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
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
          _ChartHeader(
            totalValue: widget.data.totalPanenCurrent,
            unit: widget.data.unit,
            onFilterTap: _showFilterDialog,
          ),
          const SizedBox(height: 24),
          _CategoryFilterBar(
            categories: widget.data.categories,
            onToggle: _toggleCategoryVisibility,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _MainChart(
              categories: widget.data.categories,
              unit: widget.data.unit,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGETS (PRESENTATION LAYER)
// =============================================================================

// 1. Header Section
class _ChartHeader extends StatelessWidget {
  final double totalValue;
  final String unit;
  final VoidCallback onFilterTap;

  const _ChartHeader({
    required this.totalValue,
    required this.unit,
    required this.onFilterTap,
  });

  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  _formatCurrency(totalValue),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    fontSize: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(
                    unit,
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
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: const Icon(Icons.tune_rounded,
                size: 20, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }
}

// 2. Filter Chips Section
class _CategoryFilterBar extends StatelessWidget {
  final List<HarvestCategoryData> categories;
  final Function(HarvestCategoryData, bool) onToggle;

  const _CategoryFilterBar({
    required this.categories,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _FilterChip(
              label: category.label,
              color: category.color,
              isSelected: category.isVisible,
              onTap: (val) => onToggle(category, val),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final Function(bool) onTap;

  const _FilterChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(!isSelected),
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
}

// 3. Main Chart Logic
class _MainChart extends StatelessWidget {
  final List<HarvestCategoryData> categories;
  final String unit;

  const _MainChart({required this.categories, required this.unit});

  @override
  Widget build(BuildContext context) {
    final visibleLines = categories
        .where((cat) => cat.isVisible)
        .map((cat) => _createLineData(cat))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade100, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: _bottomTitleWidgets,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: _leftTitleWidgets,
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 8,
        lineBarsData: visibleLines,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.white,
            tooltipBorder: BorderSide(color: Colors.grey.shade200),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  "${spot.y}k $unit",
                  const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );
  }

  LineChartBarData _createLineData(HarvestCategoryData category) {
    final spots = category.dataPoints
        .map((point) => FlSpot(point.monthIndex.toDouble(), point.value))
        .toList();

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

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF94A3B8));
    if (value % 2 != 0) return const SizedBox.shrink();

    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MEI',
      'JUN',
      'JUL',
      'AGU',
      'SEP',
      'OKT',
      'NOV',
      'DES'
    ];

    if (value.toInt() >= 0 && value.toInt() < months.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 10,
        child: Text(months[value.toInt()], style: style),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF94A3B8));
    return Text('${value.toInt()}k', style: style, textAlign: TextAlign.left);
  }
}

// 4. Professional Filter Dialog
class _FilterAnalysisDialog extends StatelessWidget {
  const _FilterAnalysisDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filter Analisis",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Tampilkan data berdasarkan periode atau kategori tertentu.",
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildFilterOption(
              context,
              icon: Icons.calendar_month_rounded,
              title: "Periode Waktu",
              subtitle: "Tahun Ini (2024)",
              isActive: true,
            ),
            _buildFilterOption(
              context,
              icon: Icons.pie_chart_outline_rounded,
              title: "Jenis Komoditas",
              subtitle: "Semua Komoditas",
            ),
            _buildFilterOption(
              context,
              icon: Icons.map_outlined,
              title: "Wilayah Lahan",
              subtitle: "Jawa Timur",
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text("Terapkan Filter",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFF1F5F9)
            : Colors.white, // Active vs Inactive bg
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF0F172A) : Colors.grey.shade200,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF0F172A), size: 20),
        ],
      ),
    );
  }
}