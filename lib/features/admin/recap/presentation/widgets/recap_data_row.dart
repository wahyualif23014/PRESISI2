import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';

class AppColors {
  static const Color primary = Color(0xFF673AB7);
  static const Color accent = Color(0xFFF3E5F5);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color surface = Colors.white;
}

double _sum(List<RecapModel> items, double Function(RecapModel) selector) {
  if (items.isEmpty) return 0.0;
  return items.fold(0.0, (a, b) => a + selector(b));
}

String _formatName(String name) {
  return name
      .replaceAll(RegExp(r'KABUPATEN|KAB\.', caseSensitive: false), '')
      .trim();
}

class RecapPage extends StatelessWidget {
  final List<RecapModel> allItems;
  final Map<String, List<RecapModel>> polresGroups;
  final Future<void> Function() onRefresh;

  const RecapPage({
    super.key,
    required this.allItems,
    required this.polresGroups,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 16),
          ...polresGroups.entries.map((entry) {
            return RecapPolresSection(
              polresName: entry.key,
              itemsInPolres: entry.value,
            );
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class RecapPolresSection extends StatefulWidget {
  final String polresName;
  final List<RecapModel> itemsInPolres;

  const RecapPolresSection({
    super.key,
    required this.polresName,
    required this.itemsInPolres,
  });

  @override
  State<RecapPolresSection> createState() => _RecapPolresSectionState();
}

class _RecapPolresSectionState extends State<RecapPolresSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final desaOnly =
        widget.itemsInPolres.where((e) => e.id.length > 8).toList();
    final Map<String, List<RecapModel>> grouped = {};

    for (var item in desaOnly) {
      if (item.id.length < 8) continue;
      final key = item.id.substring(0, 8);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.3),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(24),
                  bottom: Radius.circular(_isExpanded ? 0 : 24),
                ),
              ),
              child: _DataRowLayout(
                label: _formatName(widget.polresName),
                tag: "POLRES",
                potensi: _sum(desaOnly, (m) => m.potensiLahan),
                tanam: _sum(desaOnly, (m) => m.tanamLahan),
                panenLuas: _sum(desaOnly, (m) => m.panenLuas),
                panenTon: _sum(desaOnly, (m) => m.panenTon),
                serapan: _sum(desaOnly, (m) => m.serapan),
                isHeader: true,
              ),
            ),
          ),
          if (_isExpanded)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final key = sortedKeys[index];
                final items = grouped[key]!;
                return RecapPolsekSection(
                  polsekName: items.first.namaPolsek ?? "-",
                  polsekId: key,
                  itemsInPolsek: items,
                );
              },
            ),
        ],
      ),
    );
  }
}

class RecapPolsekSection extends StatefulWidget {
  final String polsekName, polsekId;
  final List<RecapModel> itemsInPolsek;

  const RecapPolsekSection({
    super.key,
    required this.polsekName,
    required this.polsekId,
    required this.itemsInPolsek,
  });

  @override
  State<RecapPolsekSection> createState() => _RecapPolsekSectionState();
}

class _RecapPolsekSectionState extends State<RecapPolsekSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, color: AppColors.border),
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _DataRowLayout(
              label: widget.polsekName,
              tag: "POLSEK",
              potensi: _sum(widget.itemsInPolsek, (m) => m.potensiLahan),
              tanam: _sum(widget.itemsInPolsek, (m) => m.tanamLahan),
              panenLuas: _sum(widget.itemsInPolsek, (m) => m.panenLuas),
              panenTon: _sum(widget.itemsInPolsek, (m) => m.panenTon),
              serapan: _sum(widget.itemsInPolsek, (m) => m.serapan),
              isSubHeader: true,
              isExpanded: _isExpanded,
            ),
          ),
        ),
        if (_isExpanded)
          ...widget.itemsInPolsek.map(
            (desa) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.grey.shade50,
              child: _DataRowLayout(
                label: desa.namaWilayah,
                tag: "DESA",
                potensi: desa.potensiLahan,
                tanam: desa.tanamLahan,
                panenLuas: desa.panenLuas,
                panenTon: desa.panenTon,
                serapan: desa.serapan,
              ),
            ),
          ),
      ],
    );
  }
}

class _DataRowLayout extends StatelessWidget {
  final String label, tag;
  final double potensi, tanam, panenLuas, panenTon, serapan;
  final bool isHeader, isSubHeader, isExpanded;

  const _DataRowLayout({
    required this.label,
    required this.tag,
    required this.potensi,
    required this.tanam,
    required this.panenLuas,
    required this.panenTon,
    required this.serapan,
    this.isHeader = false,
    this.isSubHeader = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isHeader ? 13 : 11,
                  fontWeight:
                      isHeader || isSubHeader
                          ? FontWeight.bold
                          : FontWeight.w500,
                  color: AppColors.textDark,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 2),
              _buildTag(tag),
            ],
          ),
        ),
        _buildCol(potensi, "Ha", 2),
        _buildCol(tanam, "Ha", 2),
        _buildColPanen(panenLuas, panenTon, 3),
        _buildCol(serapan, "Ton", 2),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color:
            isHeader
                ? Colors.orange
                : (isSubHeader ? Colors.blue : Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 7,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCol(double val, String unit, int flexValue) {
    return Expanded(
      flex: flexValue,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(2)} $unit",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isHeader ? AppColors.primary : AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildColPanen(double luas, double ton, int flexValue) {
    return Expanded(
      flex: flexValue,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "${luas % 1 == 0 ? luas.toInt() : luas.toStringAsFixed(2)} Ha / \n${ton % 1 == 0 ? ton.toInt() : ton.toStringAsFixed(2)} Ton",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isHeader ? AppColors.primary : AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
