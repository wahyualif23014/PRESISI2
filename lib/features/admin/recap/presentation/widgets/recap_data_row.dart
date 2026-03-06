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

class RecapPolresSection extends StatefulWidget {
  final String polresName;
  final List<RecapModel> itemsInPolres;
  final Function(String, bool) onToggle;

  const RecapPolresSection({
    super.key,
    required this.polresName,
    required this.itemsInPolres,
    required this.onToggle,
  });

  @override
  State<RecapPolresSection> createState() => _RecapPolresSectionState();
}

class _RecapPolresSectionState extends State<RecapPolresSection> {
  bool _isExpanded = false;

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
    final bool isPolresSelected =
        desaOnly.isNotEmpty && desaOnly.every((e) => e.isSelected);

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
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(24),
              bottom: Radius.circular(_isExpanded ? 0 : 24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.polresName
                          .replaceFirst("KAB. ", "POLRES\n")
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.3),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(_isExpanded ? 0 : 24),
              ),
            ),
            child: _DataRowLayout(
              label: widget.polresName,
              tag: "POLRES",
              isSelected: isPolresSelected,
              onToggle:
                  (val) => widget.onToggle(
                    widget.itemsInPolres.first.id.substring(0, 5),
                    val ?? false,
                  ),
              potensi: _sum(desaOnly, (m) => m.potensiLahan),
              tanam: _sum(desaOnly, (m) => m.tanamLahan),
              panenLuas: _sum(desaOnly, (m) => m.panenLuas),
              panenTon: _sum(desaOnly, (m) => m.panenTon),
              serapan: _sum(desaOnly, (m) => m.serapan),
              isHeader: true,
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
                  onToggle: widget.onToggle,
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
  final Function(String, bool) onToggle;

  const RecapPolsekSection({
    super.key,
    required this.polsekName,
    required this.polsekId,
    required this.itemsInPolsek,
    required this.onToggle,
  });

  @override
  State<RecapPolsekSection> createState() => _RecapPolsekSectionState();
}

class _RecapPolsekSectionState extends State<RecapPolsekSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.itemsInPolsek.every((e) => e.isSelected);

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
              isSelected: isSelected,
              onToggle: (val) => widget.onToggle(widget.polsekId, val ?? false),
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
                isSelected: desa.isSelected,
                onToggle: (val) => widget.onToggle(desa.id, val ?? false),
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
  final bool isHeader, isSubHeader, isSelected, isExpanded;
  final Function(bool?) onToggle;

  const _DataRowLayout({
    required this.label,
    required this.tag,
    required this.isSelected,
    required this.onToggle,
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
      children: [
        SizedBox(
          width: 24,
          child: Transform.scale(
            scale: 0.8,
            child: Checkbox(
              value: isSelected,
              onChanged: onToggle,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isHeader ? 12 : 10,
                  fontWeight:
                      isHeader || isSubHeader
                          ? FontWeight.w900
                          : FontWeight.w600,
                  color: AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              _buildTag(tag),
            ],
          ),
        ),
        _buildCol("POTENSI", potensi, "Ha"),
        _buildCol("TANAM", tanam, "Ha"),
        _buildColPanen(panenLuas, panenTon),
        _buildCol("SERAPAN", serapan, "Ton"),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
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

  Widget _buildCol(String title, double val, String unit) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 6,
              fontWeight: FontWeight.bold,
              color: AppColors.textGrey,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(2)} $unit",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isHeader ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColPanen(double luas, double ton) {
    return Expanded(
      flex: 3,
      child: Column(
        children: [
          const Text(
            "PANEN (HA/TON)",
            style: TextStyle(
              fontSize: 6,
              fontWeight: FontWeight.bold,
              color: AppColors.textGrey,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "${luas % 1 == 0 ? luas.toInt() : luas.toStringAsFixed(2)} Ha / ${ton % 1 == 0 ? ton.toInt() : ton.toStringAsFixed(2)} Ton",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: isHeader ? AppColors.primary : AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
