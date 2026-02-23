import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';

// --- KONFIGURASI WARNA ---
class AppColors {
  static const Color primary = Color(0xFF673AB7);
  static const Color accent = Color(0xFFF3E5F5);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color surface = Colors.white;
}

// --- FUNGSI PEMBANTU ---
double _sum(List<RecapModel> items, double Function(RecapModel) selector) {
  if (items.isEmpty) return 0.0;
  return items.map(selector).fold(0.0, (a, b) => a + b);
}

// =========================================================
// 1. SEKSI POLRES (KONTINER UTAMA)
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
    // Grouping Polsek & Hapus data yang tidak memiliki nama polsek
    final Map<String, List<RecapModel>> groupedByPolsek = {};
    for (var item in itemsInPolres) {
      final key = item.namaPolsek ?? '';
      if (key.isEmpty) continue;

      if (!groupedByPolsek.containsKey(key)) groupedByPolsek[key] = [];
      groupedByPolsek[key]!.add(item);
    }

    // Kalkulasi Total Polres
    final totalPotensi = _sum(itemsInPolres, (m) => m.potensiLahan);
    final totalTanam = _sum(itemsInPolres, (m) => m.tanamLahan);
    final totalPanenLuas = _sum(itemsInPolres, (m) => m.panenLuas);
    final totalPanenTon = _sum(itemsInPolres, (m) => m.panenTon);
    final totalSerapan = _sum(itemsInPolres, (m) => m.serapan);

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
          // Header Judul Polres
          _buildHeaderPolres(polresName),

          // Baris Total Polres
          Container(
            color: AppColors.accent.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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

          // Daftar Polsek di bawahnya
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: groupedByPolsek.length,
            separatorBuilder:
                (context, index) =>
                    const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              String key = groupedByPolsek.keys.elementAt(index);
              return RecapPolsekSection(
                polsekName: key,
                itemsInPolsek: groupedByPolsek[key]!,
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
// 2. SEKSI POLSEK (BISA DIKLIK / DROPDOWN)
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
  State<RecapPolsekSection> createState() => _RecapPolsekSectionState();
}

class _RecapPolsekSectionState extends State<RecapPolsekSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final totalPotensi = _sum(widget.itemsInPolsek, (m) => m.potensiLahan);
    final totalTanam = _sum(widget.itemsInPolsek, (m) => m.tanamLahan);
    final totalPanenLuas = _sum(widget.itemsInPolsek, (m) => m.panenLuas);
    final totalPanenTon = _sum(widget.itemsInPolsek, (m) => m.panenTon);
    final totalSerapan = _sum(widget.itemsInPolsek, (m) => m.serapan);

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color:
                _isExpanded
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
          ...widget.itemsInPolsek.map(
            (desa) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAFA),
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.5),
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
// 3. LAYOUT BARIS DATA (SENSITIF TERHADAP LEVEL)
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
        highlight || isHeader ? AppColors.primary : AppColors.textDark;

    return Row(
      children: [
        // KOLOM WILAYAH & KETERANGAN
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color:
                      isHeader
                          ? Colors.orange
                          : (isSubHeader ? Colors.blue : Colors.grey),
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
                style: TextStyle(
                  fontSize: isHeader ? 12 : 11,
                  fontWeight:
                      isHeader || isSubHeader
                          ? FontWeight.w900
                          : FontWeight.w600,
                  color: mainColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // KOLOM DATA (POTENSI & TANAM)
        _DataCell(
          value: potensi,
          unit: "HA",
          flex: 2,
          isBold: isHeader || isSubHeader,
        ),
        _DataCell(
          value: tanam,
          unit: "HA",
          flex: 2,
          isBold: isHeader || isSubHeader,
        ),

        // KOLOM PANEN (LUAS & TON)
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _TextVal(
                value: panenLuas,
                unit: "HA",
                isBold: isHeader || isSubHeader,
              ),
              const SizedBox(height: 2),
              _TextVal(
                value: panenTon,
                unit: "TN",
                isBold: isHeader || isSubHeader,
              ),
            ],
          ),
        ),

        // KOLOM SERAPAN
        _DataCell(
          value: serapan,
          unit: "TN",
          flex: 2,
          isBold: isHeader || isSubHeader,
        ),
      ],
    );
  }
}

// Widget Sel Angka
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
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: isBold ? AppColors.primary : AppColors.textDark,
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

// Widget Text Baris
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
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: isBold ? AppColors.primary : AppColors.textDark,
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
