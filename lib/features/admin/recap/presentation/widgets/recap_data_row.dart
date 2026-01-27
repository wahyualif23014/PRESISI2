import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';

// 1. LEVEL POLRES (Parent)


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
    // 1. Logic Grouping
    final Map<String, List<RecapModel>> groupedByPolsek = {};
    
    for (var item in itemsInPolres) {
      final key = item.namaPolsek ?? 'Lainnya';
      if (!groupedByPolsek.containsKey(key)) {
        groupedByPolsek[key] = [];
      }
      groupedByPolsek[key]!.add(item);
    }

    // 2. Kalkulasi Total
    final totalPotensi = _sum(itemsInPolres, (m) => m.potensiLahan);
    final totalTanam = _sum(itemsInPolres, (m) => m.tanamLahan);
    final totalPanenLuas = _sum(itemsInPolres, (m) => m.panenLuas);
    final totalPanenTon = _sum(itemsInPolres, (m) => m.panenTon);
    final avgSerapan = _avg(itemsInPolres, (m) => m.serapan);

    return ExpansionTile(
      initiallyExpanded: true,
      collapsedBackgroundColor: const Color(0xFF9FA8DA), // Warna Level 1
      backgroundColor: const Color(0xFF9FA8DA),
      iconColor: Colors.black87,
      collapsedIconColor: Colors.black87,
      
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 1.0),
            child: Text(
              polresName.toUpperCase(), // Uppercase agar tegas
              style: const TextStyle(
                fontSize: 16, // Ukuran font besar (H1)
                fontWeight: FontWeight.w800, // Sangat tebal
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // BAGIAN 2: GARIS BATAS
          Divider(
            color: Colors.black.withOpacity(0.2),
            thickness: 1,
            height: 24, // Memberi jarak atas bawah garis
          ),

          // BAGIAN 3: STATISTIK (SUMMARY)
          _RecapDataColumns(
            name: "TOTAL REKAPITULASI", // Label pengganti nama wilayah
            potensi: totalPotensi,
            tanam: totalTanam,
            panenLuas: totalPanenLuas,
            panenTon: totalPanenTon,
            serapan: avgSerapan,
            isHeader: true,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            textColor: const Color(0xFF1A237E), // Warna biru tua agar beda dikit
          ),
        ],
      ),
      children: groupedByPolsek.entries.map((entry) {
        return RecapPolsekSection(
          polsekName: entry.key,
          itemsInPolsek: entry.value,
        );
      }).toList(),
    );
  }
}

// 2. LEVEL POLSEK (Child)
class RecapPolsekSection extends StatelessWidget {
  final String polsekName;
  final List<RecapModel> itemsInPolsek;

  const RecapPolsekSection({
    super.key,
    required this.polsekName,
    required this.itemsInPolsek,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      collapsedBackgroundColor: const Color(0xFFC5CAE9), // Warna Level 2
      backgroundColor: const Color(0xFFC5CAE9),
      iconColor: Colors.black87,
      collapsedIconColor: Colors.black87,
      shape: const Border(), // Hapus border default
      title: _RecapDataColumns(
        name: "Polsek $polsekName",
        potensi: _sum(itemsInPolsek, (m) => m.potensiLahan),
        tanam: _sum(itemsInPolsek, (m) => m.tanamLahan),
        panenLuas: _sum(itemsInPolsek, (m) => m.panenLuas),
        panenTon: _sum(itemsInPolsek, (m) => m.panenTon),
        serapan: _avg(itemsInPolsek, (m) => m.serapan),
        isHeader: true,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        textColor: Colors.black87,
      ),
      children: itemsInPolsek.map((data) => RecapDesaRow(data: data)).toList(),
    );
  }
}

// 3. LEVEL DESA (Leaf/Item)

class RecapDesaRow extends StatelessWidget {
  final RecapModel data;

  const RecapDesaRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ), // Padding disesuaikan dengan ExpansionTile
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: _RecapDataColumns(
        name: data.namaWilayah,
        potensi: data.potensiLahan,
        tanam: data.tanamLahan,
        panenLuas: data.panenLuas,
        panenTon: data.panenTon,
        serapan: data.serapan,
        isHeader: false,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        textColor: Colors.black87,
      ),
    );
  }
}

class _RecapDataColumns extends StatelessWidget {
  final String name;
  final double potensi;
  final double tanam;
  final double panenLuas;
  final double panenTon;
  final double serapan;
  final bool isHeader;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;

  const _RecapDataColumns({
    required this.name,
    required this.potensi,
    required this.tanam,
    required this.panenLuas,
    required this.panenTon,
    required this.serapan,
    required this.isHeader,
    required this.fontSize,
    required this.fontWeight,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor,
    );

    return Row(
      children: [
        // Kolom Nama Wilayah
        Expanded(
          flex: 3,
          child: Text(
            name,
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Kolom Potensi
        _buildCell("${potensi.toInt()} HA", style, 2),
        // Kolom Tanam
        _buildCell("${tanam.toInt()} HA", style, 2),
        // Kolom Panen (Gabungan Luas/Ton)
        _buildCell(
          "${panenLuas.toStringAsFixed(0)} HA / ${panenTon.toStringAsFixed(0)} TON",
          style,
          3,
        ),
        // Kolom Serapan
        _buildCell("${serapan.toInt()}%", style, 2),
      ],
    );
  }

  Widget _buildCell(String text, TextStyle style, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

double _sum(List<RecapModel> items, double Function(RecapModel) selector) {
  if (items.isEmpty) return 0.0;
  return items.map(selector).reduce((a, b) => a + b);
}

double _avg(List<RecapModel> items, double Function(RecapModel) selector) {
  if (items.isEmpty) return 0.0;
  final total = items.map(selector).reduce((a, b) => a + b);
  return total / items.length;
}
