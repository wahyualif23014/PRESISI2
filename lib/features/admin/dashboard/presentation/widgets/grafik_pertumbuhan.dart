import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
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
            onToggle: (cat, isVisible) => setState(() => cat.isVisible = isVisible),
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
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  totalValue.toStringAsFixed(1).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},'),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final List<HarvestCategoryData> categories;
  final Function(HarvestCategoryData, bool) onToggle;

  const _CategoryFilterBar({required this.categories, required this.onToggle});

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? category.color : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? category.color : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    size: 16,
                    color: isSelected ? Colors.white : category.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.label,
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
  static const _months = <String>[
    'JAN', 'FEB', 'MAR', 'APR', 'MEI', 'JUN', 'JUL', 'AGU', 'SEP', 'OKT', 'NOV', 'DES'
  ];

  static const int _minMonth = 0;
  static const int _maxMonth = 11;
  static const int _minVisibleMonths = 3;
  static const int _maxVisibleMonths = 12;

  int _visibleMonths = 12;
  int _startMonth = 0;

  int _startVisibleMonths = 12;
  int _startStartMonth = 0;
  double _startFocalDx = 0;
  double _startFocalRatio = 0.5;

  void _resetView() {
    setState(() {
      _visibleMonths = 12;
      _startMonth = 0;
    });
  }

  void _applyViewport({required int visibleMonths, required int startMonth}) {
    final v = visibleMonths.clamp(_minVisibleMonths, _maxVisibleMonths);
    final maxStart = _maxMonth - v + 1;
    final s = startMonth.clamp(_minMonth, maxStart);

    setState(() {
      _visibleMonths = v;
      _startMonth = s;
    });
  }

  int _labelStep({required int visibleMonths, required double width}) {
    // target jarak minimum antar label ~44px biar tidak dempet
    final maxLabels = ((width / 44).floor()).clamp(2, 12).toInt();
    final step = ((visibleMonths / maxLabels).ceil()).clamp(1, 6).toInt();
    return step;
  }

  void _zoomFromWheel({
    required double dy,
    required double width,
    required double focalDx,
  }) {
    final zoomIn = dy < 0;
    final nextVisible = (zoomIn ? _visibleMonths - 1 : _visibleMonths + 1)
        .clamp(_minVisibleMonths, _maxVisibleMonths);

    if (nextVisible == _visibleMonths) return;

    final ratio = ((focalDx / width).clamp(0.0, 1.0)).toDouble();

    final oldStart = _startMonth;
    final oldVisible = _visibleMonths;
    final focalMonth = oldStart + ((oldVisible - 1) * ratio).round();

    final newStart = focalMonth - ((nextVisible - 1) * ratio).round();
    _applyViewport(visibleMonths: nextVisible, startMonth: newStart);
  }

  @override
  Widget build(BuildContext context) {
    final visibleCats = widget.categories.where((c) => c.isVisible).toList();

    if (visibleCats.isEmpty) {
      return const Center(child: Text("Aktifkan minimal 1 kategori"));
    }

    final visibleLines = visibleCats.map((cat) {
      return LineChartBarData(
        spots: cat.dataPoints
            .map((p) => FlSpot(p.monthIndex.toDouble(), p.value))
            .toList(),
        isCurved: true,
        color: cat.color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [cat.color.withOpacity(0.18), cat.color.withOpacity(0.0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }).toList();

    final minX = _startMonth.toDouble();
    final maxX = (_startMonth + _visibleMonths - 1).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final step = _labelStep(visibleMonths: _visibleMonths, width: width);

        final rotateLabels = _visibleMonths >= 9 && step == 1;
        final reservedBottom = rotateLabels ? 36.0 : 28.0;

        return MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                _zoomFromWheel(
                  dy: event.scrollDelta.dy,
                  width: width,
                  focalDx: event.localPosition.dx,
                );
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: _resetView,

              onScaleStart: (d) {
                _startVisibleMonths = _visibleMonths;
                _startStartMonth = _startMonth;
                _startFocalDx = d.localFocalPoint.dx;
                _startFocalRatio =
                    ((_startFocalDx / width).clamp(0.0, 1.0)).toDouble();
              },

              onScaleUpdate: (d) {
                final nextVisible = (_startVisibleMonths / d.scale)
                    .round()
                    .clamp(_minVisibleMonths, _maxVisibleMonths);

                // zoom anchored ke focal point saat gesture dimulai
                final focalMonth =
                    _startStartMonth + ((_startVisibleMonths - 1) * _startFocalRatio).round();
                var nextStart =
                    focalMonth - ((nextVisible - 1) * _startFocalRatio).round();

                // pan horizontal
                final dx = d.localFocalPoint.dx - _startFocalDx;
                final shift = (-dx / width * nextVisible).round();
                nextStart += shift;

                _applyViewport(visibleMonths: nextVisible, startMonth: nextStart);
              },

              child: LineChart(
                LineChartData(
                  clipData: const FlClipData.all(),
                  minX: minX,
                  maxX: maxX,
                  minY: 0,
                  maxY: widget.maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: reservedBottom,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i > 11) return const SizedBox.shrink();

                          // selalu tampilkan label start window, lalu selanjutnya mengikuti step
                          final relative = i - _startMonth;
                          if (relative < 0 || relative >= _visibleMonths) {
                            return const SizedBox.shrink();
                          }
                          if (relative % step != 0) return const SizedBox.shrink();

                          final angle = rotateLabels ? -0.65 : 0.0;

                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 10,
                            child: Transform.rotate(
                              angle: angle,
                              child: Text(
                                _months[i],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
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
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: visibleLines,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => Colors.white,
                      getTooltipItems: (spots) => spots.map((s) {
                        final idx = s.x.round().clamp(0, 11);
                        final month = _months[idx];
                        return LineTooltipItem(
                          "$month\n${s.y.toStringAsFixed(1)} ${widget.unit}",
                          TextStyle(
                            fontWeight: FontWeight.w800,
                            color: s.bar.color,
                            height: 1.2,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
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

    // Pastikan list filter sudah ada
    final provider = context.read<DashboardProvider>();
    provider.initFilters(); // aman dipanggil berkali-kali, kalau kamu mau bisa guard di provider
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

            final komoditiEnabled = selectedJenis != null && selectedJenis.trim().isNotEmpty;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filter Analisis",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Pilih jenis komoditi dan tanaman untuk memperbarui grafik.",
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),

                // ===== Jenis Komoditi =====
                const Text(
                  "Jenis Komoditi",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedJenis,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: "Pilih jenis komoditi",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text("Semua Jenis"),
                    ),
                    ...jenisItems.map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ),
                    ),
                  ],
                  onChanged: (value) async {
                    // value null = semua
                    await p.selectJenisKomoditi(value);
                  },
                ),

                const SizedBox(height: 16),

                // ===== Nama Tanaman (Komoditi) =====
                const Text(
                  "Nama Tanaman",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedKomoditiId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: komoditiEnabled ? "Pilih tanaman" : "Pilih jenis dulu",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text("Semua Tanaman"),
                    ),
                    ...komoditiItems.map(
                      (k) => DropdownMenuItem<String>(
                        value: k.id,
                        child: Text(k.label),
                      ),
                    ),
                  ],
                  onChanged: komoditiEnabled
                      ? (value) async {
                          await p.selectKomoditi(value);
                        }
                      : null,
                ),

                const SizedBox(height: 20),

                // ===== Actions =====
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // Reset selection (sesuaikan jika method reset belum ada)
                          await p.selectJenisKomoditi(null);
                          await p.selectKomoditi(null);
                          await p.fetchDashboard();
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
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