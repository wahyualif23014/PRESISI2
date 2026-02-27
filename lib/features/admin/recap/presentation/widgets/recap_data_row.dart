import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';

// =========================================================
// WARNA (TIDAK DIUBAH)
// =========================================================
class AppColors {
  static const Color primary = Color(0xFF673AB7);
  static const Color accent = Color(0xFFF3E5F5);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color surface = Colors.white;
}

// =========================================================
// HELPER SUM
// =========================================================
double _sum(
  List<RecapModel> items,
  double Function(RecapModel) selector,
) {
  if (items.isEmpty) return 0.0;
  return items.fold(0.0, (a, b) => a + selector(b));
}

// =========================================================
// 1. POLRES SECTION
// =========================================================
class RecapPolresSection extends StatelessWidget {
  final String polresName;
  final List<RecapModel> itemsInPolres;

  const RecapPolresSection({
    super.key,
    required this.polresName,
    required this.itemsInPolres,
  });

  @override
  Widget build(BuildContext context) {
    // DESA = id lebih dari 8 karakter
    final desaOnly =
        itemsInPolres.where((e) => e.id.length > 8).toList();

    // GROUP BY KODE POLSEK (8 digit pertama)
    final Map<String, List<RecapModel>> grouped = {};

    for (var item in desaOnly) {
      if (item.id.length < 8) continue;
      final key = item.id.substring(0, 8);

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    // TOTAL POLRES
    final totalPotensi = _sum(desaOnly, (m) => m.potensiLahan);
    final totalTanam = _sum(desaOnly, (m) => m.tanamLahan);
    final totalPanenLuas = _sum(desaOnly, (m) => m.panenLuas);
    final totalPanenTon = _sum(desaOnly, (m) => m.panenTon);
    final totalSerapan = _sum(desaOnly, (m) => m.serapan);

    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildHeaderPolres(polresName),

          Container(
            color: AppColors.accent.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            child: _DataRowLayout(
              label: polresName,
              tag: "POLRES",
              potensi: totalPotensi,
              tanam: totalTanam,
              panenLuas: totalPanenLuas,
              panenTon: totalPanenTon,
              serapan: totalSerapan,
              isHeader: true,
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedKeys.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final key = sortedKeys[index];
              final items = grouped[key]!;

              // Sort desa biar stabil
              items.sort((a, b) => a.id.compareTo(b.id));

              return RecapPolsekSection(
                key: ValueKey(key),
                polsekName: items.first.namaPolsek ?? "-",
                itemsInPolsek: items,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPolres(String name) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.location_city_rounded,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            name.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// 2. POLSEK SECTION
// =========================================================
class RecapPolsekSection extends StatefulWidget {
  final String polsekName;
  final List<RecapModel> itemsInPolsek;

  const RecapPolsekSection({
    super.key,
    required this.polsekName,
    required this.itemsInPolsek,
  });

  @override
  State<RecapPolsekSection> createState() =>
      _RecapPolsekSectionState();
}

class _RecapPolsekSectionState
    extends State<RecapPolsekSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final desaOnly =
        widget.itemsInPolsek.where((e) => e.id.length > 8).toList();

    final totalPotensi = _sum(desaOnly, (m) => m.potensiLahan);
    final totalTanam = _sum(desaOnly, (m) => m.tanamLahan);
    final totalPanenLuas = _sum(desaOnly, (m) => m.panenLuas);
    final totalPanenTon = _sum(desaOnly, (m) => m.panenTon);
    final totalSerapan = _sum(desaOnly, (m) => m.serapan);

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            color: _isExpanded
                ? AppColors.accent.withOpacity(0.3)
                : Colors.transparent,
            child: _DataRowLayout(
              label: widget.polsekName,
              tag: "POLSEK",
              potensi: totalPotensi,
              tanam: totalTanam,
              panenLuas: totalPanenLuas,
              panenTon: totalPanenTon,
              serapan: totalSerapan,
              isSubHeader: true,
              highlight: _isExpanded,
            ),
          ),
        ),
        if (_isExpanded)
          ...desaOnly.map(
            (desa) => Container(
              key: ValueKey(desa.id),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                    width: 0.5,
                  ),
                ),
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
            ),
          ),
      ],
    );
  }
}

// =========================================================
// 3. DATA ROW (UI TIDAK DIUBAH)
// =========================================================
class _DataRowLayout extends StatelessWidget {
  final String label;
  final String tag;
  final double potensi, tanam, panenLuas, panenTon, serapan;
  final bool isHeader, isSubHeader, highlight;

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
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor =
        highlight || isHeader
            ? AppColors.primary
            : AppColors.textDark;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isHeader
                      ? Colors.orange
                      : (isSubHeader
                          ? Colors.blue
                          : Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isHeader ? 12 : 11,
                  fontWeight: isHeader || isSubHeader
                      ? FontWeight.w900
                      : FontWeight.w600,
                  color: mainColor,
                ),
              ),
            ],
          ),
        ),
        _DataCell(
            value: potensi,
            unit: "HA",
            flex: 2,
            isBold: isHeader || isSubHeader),
        _DataCell(
            value: tanam,
            unit: "HA",
            flex: 2,
            isBold: isHeader || isSubHeader),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _TextVal(
                  value: panenLuas,
                  unit: "HA",
                  isBold: isHeader || isSubHeader),
              const SizedBox(height: 2),
              _TextVal(
                  value: panenTon,
                  unit: "TN",
                  isBold: isHeader || isSubHeader),
            ],
          ),
        ),
        _DataCell(
            value: serapan,
            unit: "TN",
            flex: 2,
            isBold: isHeader || isSubHeader),
      ],
    );
  }
}

class _DataCell extends StatelessWidget {
  final double value;
  final String unit;
  final int flex;
  final bool isBold;

  const _DataCell({
    required this.value,
    required this.unit,
    required this.flex,
    required this.isBold,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Text(
            value.toInt().toString(),
            style: TextStyle(
              fontSize: isBold ? 13 : 12,
              fontWeight:
                  isBold ? FontWeight.w900 : FontWeight.w700,
              color: isBold
                  ? AppColors.primary
                  : AppColors.textDark,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextVal extends StatelessWidget {
  final double value;
  final String unit;
  final bool isBold;

  const _TextVal({
    required this.value,
    required this.unit,
    required this.isBold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toInt().toString(),
          style: TextStyle(
            fontSize: isBold ? 11 : 10,
            fontWeight:
                isBold ? FontWeight.w900 : FontWeight.w700,
            color: isBold
                ? AppColors.primary
                : AppColors.textDark,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.bold,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}