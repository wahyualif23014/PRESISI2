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

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          tilePadding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
          iconColor: Colors.grey.shade600,
          collapsedIconColor: Colors.grey.shade600,

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- H1: HEADER NAME ---
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    polresName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // --- DIVIDER ---
              Divider(color: Colors.grey.shade200, thickness: 1.5, height: 1),

              const SizedBox(height: 12),

              // --- H2: LABEL JUDUL TOTAL ---
              // Dipisah ke atas sesuai request
              const Text(
                "TOTAL REKAPITULASI",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B), // Slate Grey (Muted)
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 8), // Jarak antara H2 dan Angka

              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Rata atas
                children: [
                  const Expanded(flex: 3, child: SizedBox()),

                  _buildStackedCell(totalPotensi.toInt().toString(), "HA", 2),

                  // Flex 2: Tanam
                  _buildStackedCell(totalTanam.toInt().toString(), "HA", 2),

                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF1A237E),
                              fontFamily: 'Roboto',
                            ), // Pastikan font family sama
                            children: [
                              TextSpan(
                                text: "${totalPanenLuas.toStringAsFixed(0)} ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              const TextSpan(
                                text: "HA",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ), // Jarak tipis antar baris panen
                        Container(
                          height: 1,
                          width: 20,
                          color: Colors.grey.shade300,
                        ), // Garis pemisah kecil
                        const SizedBox(height: 2),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF1A237E),
                              fontFamily: 'Roboto',
                            ),
                            children: [
                              TextSpan(
                                text: "${totalPanenTon.toStringAsFixed(0)} ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              const TextSpan(
                                text: "TON",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flex 2: Serapan
                  _buildStackedCell("${avgSerapan.toInt()}", "%", 2),
                ],
              ),
            ],
          ),
          children:
              groupedByPolsek.entries.map((entry) {
                return RecapPolsekSection(
                  polsekName: entry.key,
                  itemsInPolsek: entry.value,
                );
              }).toList(),
        ),
      ),
    );
  }

  // --- HELPER UNTUK TAMPILAN NOMOR DI ATAS SATUAN ---
  Widget _buildStackedCell(String value, String unit, int flex) {
    return Expanded(
      flex: flex,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800, // Extra Bold
              color: Color(0xFF1A237E), // Indigo Primary
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8), // Slate 400
            ),
          ),
        ],
      ),
    );
  }
}

// 2. LEVEL POLSEK

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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(
          0xFFE8EAF6,
        ), // Indigo 50 (Lebih soft dari C5CAE9 agar teks terbaca)
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFC5CAE9),
        ), // Border lebih tua dikit
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: const Border(), // Hapus border default
        iconColor: const Color(0xFF1A237E),
        collapsedIconColor: Colors.grey.shade700,
        tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),

        // CUSTOM TITLE: COLUMN (Nama -> Garis -> Data)
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. NAMA POLSEK
            Row(
              children: [
                const Icon(
                  Icons.location_city,
                  size: 18,
                  color: Color(0xFF3949AB),
                ),
                const SizedBox(width: 8),
                Text(
                  "POLSEK $polsekName".toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A237E),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 2. GARIS PEMISAH TIPIS
            Divider(color: Colors.indigo.shade100, thickness: 1),

            const SizedBox(height: 8),

            // 3. DATA TOTAL POLSEK (Layout Stacked Besar)
            _RecapDataColumns(
              name: "TOTAL",
              potensi: _sum(itemsInPolsek, (m) => m.potensiLahan),
              tanam: _sum(itemsInPolsek, (m) => m.tanamLahan),
              panenLuas: _sum(itemsInPolsek, (m) => m.panenLuas),
              panenTon: _sum(itemsInPolsek, (m) => m.panenTon),
              serapan: _avg(itemsInPolsek, (m) => m.serapan),
              isHeader: true, // Mode Bold & Warna Tua
            ),
          ],
        ),
        children:
            itemsInPolsek.map((data) => RecapDesaRow(data: data)).toList(),
      ),
    );
  }
}

// 3. LEVEL DESA

class RecapDesaRow extends StatelessWidget {
  final RecapModel data;

  const RecapDesaRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          // Garis putus-putus atau solid tipis untuk pemisah desa
          bottom: BorderSide(color: Colors.grey.shade100, width: 1.0),
        ),
      ),
      child: _RecapDataColumns(
        name: data.namaWilayah,
        potensi: data.potensiLahan,
        tanam: data.tanamLahan,
        panenLuas: data.panenLuas,
        panenTon: data.panenTon,
        serapan: data.serapan,
        isHeader: false, // Mode Regular (Hitam/Abu)
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

  const _RecapDataColumns({
    required this.name,
    required this.potensi,
    required this.tanam,
    required this.panenLuas,
    required this.panenTon,
    required this.serapan,
    required this.isHeader,
  });

  @override
  Widget build(BuildContext context) {
    // Style Nama Wilayah
    final nameStyle = TextStyle(
      fontSize: 12, // Tetap compact agar muat
      fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
      color: isHeader ? Colors.indigo.shade900 : Colors.black87,
    );

    final numberColor =
        isHeader ? const Color(0xFF1A237E) : const Color(0xFF1E293B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child:
                isHeader && name == "TOTAL"
                    ? const Text(
                      "SUB-TOTAL", // Label kecil pengganti nama polsek di baris data
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )
                    : Text(
                      name,
                      style: nameStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
          ),
        ),

        // KOLOM 2: POTENSI (Flex 2)
        _buildStackedCell(potensi.toInt().toString(), "HA", 2, numberColor),

        // KOLOM 3: TANAM (Flex 2)
        _buildStackedCell(tanam.toInt().toString(), "HA", 2, numberColor),

        // KOLOM 4: PANEN (Flex 3)
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMicroRow(panenLuas.toStringAsFixed(0), "HA", numberColor),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                height: 1,
                width: 24,
                color: Colors.grey.shade300,
              ),
              _buildMicroRow(panenTon.toStringAsFixed(0), "TON", numberColor),
            ],
          ),
        ),

        // KOLOM 5: SERAPAN (Flex 2)
        _buildStackedCell("${serapan.toInt()}", "%", 2, numberColor),
      ],
    );
  }

  Widget _buildStackedCell(String value, String unit, int flex, Color color) {
    final double fontSize = isHeader ? 14 : 13;

    return Expanded(
      flex: flex,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800, // Extra Bold agar jelas
              color: color,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            unit,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Panen (Baris Kecil)
  Widget _buildMicroRow(String val, String unit, Color color) {
    // Font size panen juga disesuaikan
    final double fontSize = isHeader ? 12 : 11;

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontFamily: 'Roboto'),
        children: [
          TextSpan(
            text: "$val ",
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: unit,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Functions ---
double _sum(List<RecapModel> items, double Function(RecapModel) selector) {
  if (items.isEmpty) return 0.0;
  return items.map(selector).reduce((a, b) => a + b);
}

double _avg(List<RecapModel> items, double Function(RecapModel) selector) {
  if (items.isEmpty) return 0.0;
  final total = items.map(selector).reduce((a, b) => a + b);
  return total / items.length;
}
