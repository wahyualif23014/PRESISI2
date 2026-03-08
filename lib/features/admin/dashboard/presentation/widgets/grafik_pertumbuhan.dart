import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/harvest_model.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/providers/dashboard_provider.dart';

class GrafikChartCard extends StatefulWidget {
  final HarvestModel data;

  const GrafikChartCard({super.key, required this.data});

  @override
  State<GrafikChartCard> createState() => _GrafikChartCardState();
}

class _GrafikChartCardState extends State<GrafikChartCard> {

  double get _calculateMaxY {
    double maxVal = 0;
    for (var cat in widget.data.categories) {
      if (!cat.isVisible) continue;
      for (var pt in cat.dataPoints) {
        if (pt.value > maxVal) maxVal = pt.value;
      }
    }
    return maxVal == 0 ? 10 : maxVal * 1.2;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => const _FilterAnalysisDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (widget.data.categories.isEmpty) {
      return const Center(child: Text("Tidak ada data panen tersedia"));
    }

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
            onToggle: (cat, isVisible) =>
                setState(() => cat.isVisible = isVisible),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: _MainChart(
              categories: widget.data.categories,
              unit: widget.data.unit,
              maxY: _calculateMaxY,
            ),
          ),

        ],
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {

  final double totalValue;
  final String unit;
  final VoidCallback onFilterTap;

  const _ChartHeader({
    required this.totalValue,
    required this.unit,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 4),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                Text(
                  totalValue
                      .toStringAsFixed(1)
                      .replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                  ),
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

        IconButton(
          onPressed: onFilterTap,
          icon: const Icon(Icons.tune_rounded, color: Color(0xFF64748B)),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

      ],
    );
  }
}

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

          final isSelected = category.isVisible;

          return GestureDetector(
            onTap: () => onToggle(category, !isSelected),

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              decoration: BoxDecoration(
                color: isSelected ? category.color : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? category.color
                      : Colors.grey.shade300,
                ),
              ),

              child: Row(
                children: [

                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : category.color,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    category.label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),

                ],
              ),
            ),
          );

        }).toList(),
      ),
    );
  }
}

class _MainChart extends StatefulWidget {

  final List<HarvestCategoryData> categories;
  final String unit;
  final double maxY;

  const _MainChart({
    required this.categories,
    required this.unit,
    required this.maxY,
  });

  @override
  State<_MainChart> createState() => _MainChartState();
}

class _MainChartState extends State<_MainChart> {

  static const _months = [
    'JAN','FEB','MAR','APR','MEI','JUN',
    'JUL','AGU','SEP','OKT','NOV','DES'
  ];

  int _visibleMonths = 12;
  int _startMonth = 0;

  int _calculateLabelStep(double width) {
    if (width < 400) return 3;
    if (width < 650) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {

    final visibleCats =
    widget.categories.where((c) => c.isVisible).toList();

    if (visibleCats.isEmpty) {
      return const Center(child: Text("Aktifkan minimal 1 kategori"));
    }

    final lines = visibleCats.map((cat) {

      return LineChartBarData(
        spots: cat.dataPoints
            .map((p) => FlSpot(p.monthIndex.toDouble(), p.value))
            .toList(),

        isCurved: true,
        curveSmoothness: 0.35,
        preventCurveOverShooting: true,

        color: cat.color,
        barWidth: 3.2,
        isStrokeCapRound: true,

        dotData: const FlDotData(show: false),

        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              cat.color.withOpacity(0.18),
              cat.color.withOpacity(0)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );

    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {

        final step = _calculateLabelStep(constraints.maxWidth);

        return LineChart(
          LineChartData(

            minX: _startMonth.toDouble(),
            maxX: (_startMonth + _visibleMonths - 1).toDouble(),

            minY: 0,
            maxY: widget.maxY,

            borderData: FlBorderData(show: false),

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) =>
                  FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
            ),

            lineBarsData: lines,

            titlesData: FlTitlesData(

              rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),

              topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: step.toDouble(),
                  reservedSize: 34,

                  getTitlesWidget: (value, meta) {

                    final i = value.toInt();
                    if (i < 0 || i > 11) return const SizedBox();

                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 8,

                      child: Text(
                        _months[i],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    );
                  },
                ),
              ),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,

                  getTitlesWidget: (value, meta) {

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            lineTouchData: LineTouchData(

              enabled: true,
              handleBuiltInTouches: true,

              getTouchedSpotIndicator:
                  (LineChartBarData barData, List<int> indicators) {

                return indicators.map((index) {

                  return TouchedSpotIndicatorData(

                    FlLine(
                      color: Colors.grey.shade300.withOpacity(0.6),
                      strokeWidth: 1,
                      dashArray: [6,4],
                    ),

                    FlDotData(
                      getDotPainter:
                          (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 5,
                            color: bar.color ?? Colors.blue,
                            strokeWidth: 3,
                            strokeColor: Colors.white,
                          ),
                    ),

                  );

                }).toList();
              },

              touchTooltipData: LineTouchTooltipData(

                tooltipRoundedRadius: 14,

                tooltipMargin: 12,

                tooltipPadding:
                const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),

                fitInsideHorizontally: true,
                fitInsideVertically: true,

                maxContentWidth: 190,

                getTooltipColor: (_) => Colors.white,

                getTooltipItems: (spots) {

                  if (spots.isEmpty) return [];

                  final monthIndex =
                  spots.first.x.toInt().clamp(0,11);

                  final month = _months[monthIndex];

                  return spots.map((spot) {

                    final category =
                    visibleCats[spot.barIndex];

                    return LineTooltipItem(

                      "$month\n\n"
                      "${category.label.padRight(10)} "
                      "${spot.y.toStringAsFixed(1)} ${widget.unit}",

                      TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: category.color,
                      ),
                    );

                  }).toList();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilterAnalysisDialog extends StatefulWidget {
  const _FilterAnalysisDialog();

  @override
  State<_FilterAnalysisDialog> createState() => _FilterAnalysisDialogState();
}

class _FilterAnalysisDialogState extends State<_FilterAnalysisDialog> {
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInit) return;
    _didInit = true;

    final provider = context.read<DashboardProvider>();
    provider.initFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Consumer<DashboardProvider>(
          builder: (context, p, _) {
            final jenisItems = p.jenisKomoditiList;
            final komoditiItems = p.komoditiList;

            final selectedJenis = p.selectedJenisKomoditi;
            final selectedKomoditiId = p.selectedKomoditiId;

            final komoditiEnabled =
                selectedJenis != null && selectedJenis.trim().isNotEmpty;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filter Analisis",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedJenis,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: "Pilih jenis komoditi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("Semua Jenis"),
                    ),
                    ...jenisItems.map(
                      (e) => DropdownMenuItem(value: e, child: Text(e)),
                    ),
                  ],
                  onChanged: (value) async {
                    await p.selectJenisKomoditi(value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedKomoditiId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText:
                        komoditiEnabled ? "Pilih tanaman" : "Pilih jenis dulu",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("Semua Tanaman"),
                    ),
                    ...komoditiItems.map(
                      (k) =>
                          DropdownMenuItem(value: k.id, child: Text(k.label)),
                    ),
                  ],
                  onChanged:
                      komoditiEnabled
                          ? (value) async {
                            await p.selectKomoditi(value);
                          }
                          : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await p.selectJenisKomoditi(null);
                          await p.selectKomoditi(null);
                          await p.fetchDashboard();
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text("Reset"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await p.fetchDashboard();
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text("Terapkan"),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
