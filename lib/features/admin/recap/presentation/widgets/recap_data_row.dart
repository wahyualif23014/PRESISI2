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
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        itemCount: polresGroups.length,
        itemBuilder: (context, index) {
          final polresName = polresGroups.keys.elementAt(index);
          final items = polresGroups[polresName]!;
          return RecapPolresSection(
            polresName: polresName,
            itemsInPolres: items,
          );
        },
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
    // Memfilter hanya data desa (id > 8 karakter)
    final desaOnly =
        widget.itemsInPolres.where((e) => e.id.length > 8).toList();

    // Mengelompokkan desa berdasarkan polsek (menggunakan 8 karakter pertama ID)
    final Map<String, List<RecapModel>> groupedByPolsek = {};
    for (var item in desaOnly) {
      if (item.id.length < 8) continue;
      final key = item.id.substring(0, 8);
      groupedByPolsek.putIfAbsent(key, () => []);
      groupedByPolsek[key]!.add(item);
    }

    final sortedPolsekKeys = groupedByPolsek.keys.toList()..sort();

    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER POLRES
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: Colors.orange.shade900,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
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
                ],
              ),
            ),
          ),

          // 2. LIST POLSEK (Hanya tampil jika di-expand)
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedPolsekKeys.length,
                itemBuilder: (context, index) {
                  final key = sortedPolsekKeys[index];
                  final items = groupedByPolsek[key]!;
                  return RecapPolsekSection(
                    polsekName:
                        items.first.namaPolsek ?? "POLSEK TIDAK DIKETAHUI",
                    itemsInPolsek: items,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class RecapPolsekSection extends StatefulWidget {
  final String polsekName;
  final List<RecapModel> itemsInPolsek;

  const RecapPolsekSection({
    super.key,
    required this.polsekName,
    required this.itemsInPolsek,
  });

  @override
  State<RecapPolsekSection> createState() => _RecapPolsekSectionState();
}

class _RecapPolsekSectionState extends State<RecapPolsekSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER POLSEK
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    _isExpanded
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    size: 18,
                    color: Colors.blue.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DataRowLayout(
                      label: widget.polsekName,
                      tag: "POLSEK",
                      potensi: _sum(
                        widget.itemsInPolsek,
                        (m) => m.potensiLahan,
                      ),
                      tanam: _sum(widget.itemsInPolsek, (m) => m.tanamLahan),
                      panenLuas: _sum(widget.itemsInPolsek, (m) => m.panenLuas),
                      panenTon: _sum(widget.itemsInPolsek, (m) => m.panenTon),
                      serapan: _sum(widget.itemsInPolsek, (m) => m.serapan),
                      isSubHeader: true,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. LIST DESA (Hanya tampil jika di-expand)
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16),
              child: Column(
                children:
                    widget.itemsInPolsek.map((desa) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: _DataRowLayout(
                          label: desa.namaWilayah,
                          tag: "DESA",
                          potensi: desa.potensiLahan,
                          tanam: desa.tanamLahan,
                          panenLuas: desa.panenLuas,
                          panenTon: desa.panenTon,
                          serapan: desa.serapan,
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _DataRowLayout extends StatelessWidget {
  final String label, tag;
  final double potensi, tanam, panenLuas, panenTon, serapan;
  final bool isHeader, isSubHeader;

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
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Kolom Nama Wilayah
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
              const SizedBox(height: 4),
              _buildTag(tag),
            ],
          ),
        ),
        // Kolom Data Angka
        _buildCol(potensi, "Ha", 2),
        _buildCol(tanam, "Ha", 2),
        _buildColPanen(panenLuas, panenTon, 3),
        _buildCol(serapan, "Ton", 2),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            isHeader
                ? Colors.orange.shade700
                : (isSubHeader ? Colors.blue.shade600 : Colors.grey.shade600),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
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
            fontWeight: FontWeight.bold,
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
          "${luas % 1 == 0 ? luas.toInt() : luas.toStringAsFixed(2)} Ha\n${ton % 1 == 0 ? ton.toInt() : ton.toStringAsFixed(2)} Ton",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isHeader ? AppColors.primary : AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
