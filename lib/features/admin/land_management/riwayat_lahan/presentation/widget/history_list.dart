import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/models/lahan_history_model.dart';

// =========================================================
// LEVEL 1: GROUP WILAYAH (KAB/KEC/DESA) - UNGU TUA
// =========================================================
class HistoryRegionExpansionTile extends StatelessWidget {
  final String title;
  final List<LandHistoryItemModel> items;

  const HistoryRegionExpansionTile({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, List<LandHistoryItemModel>> groupedByDusun = {};
    for (var item in items) {
      if (!groupedByDusun.containsKey(item.subRegionGroup)) {
        groupedByDusun[item.subRegionGroup] = [];
      }
      groupedByDusun[item.subRegionGroup]!.add(item);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 0),
      elevation: 0,
      shape: const Border(bottom: BorderSide(color: Colors.black12)),
      child: ExpansionTile(
        initiallyExpanded: true,
        collapsedBackgroundColor: const Color(0xFFC5CAE9),
        backgroundColor: const Color(0xFFC5CAE9),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        children:
            groupedByDusun.entries.map((entry) {
              return HistorySubRegionExpansionTile(
                title: entry.key,
                items: entry.value,
              );
            }).toList(),
      ),
    );
  }
}

// =========================================================
// LEVEL 2: GROUP DUSUN - UNGU MUDA (DENGAN FIX WRAP TEXT)
// =========================================================
class HistorySubRegionExpansionTile extends StatelessWidget {
  final String title;
  final List<LandHistoryItemModel> items;

  const HistorySubRegionExpansionTile({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    double totalLuas = 0;
    for (var item in items) {
      totalLuas += item.landArea;
    }

    return Container(
      color: const Color(0xFFE8EAF6),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                // FIX: Gunakan Expanded agar nama dusun/jalan yang panjang pindah ke bawah
                Expanded(
                  child: Text(
                    title.isEmpty || title == '-'
                        ? 'ALAMAT TIDAK TERDATA'
                        : title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Total: ${totalLuas.toStringAsFixed(2)} Ha",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: items.map((item) => HistoryRow(item: item)).toList(),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// LEVEL 3: DATA ITEM ROW (4 KOLOM)
// =========================================================
class HistoryRow extends StatelessWidget {
  final LandHistoryItemModel item;
  const HistoryRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    Color statusColor = const Color(0xFF9E9E9E);
    try {
      if (item.statusColor.isNotEmpty) {
        statusColor = Color(
          int.parse(item.statusColor.replaceAll('#', '0xFF')),
        );
      }
    } catch (_) {}

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. POLISI
          Expanded(
            flex: 4,
            child: _buildTextCell(item.policeName, item.policePhone),
          ),

          // 2. PJ
          Expanded(flex: 4, child: _buildTextCell(item.picName, item.picPhone)),

          // 3. VALIDASI
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // 4. DETAIL (MATA)
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _showFullDetail(context, item),
              child: const Center(
                child: Icon(
                  Icons.visibility_outlined,
                  color: Colors.deepPurple,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextCell(String name, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name.isEmpty ? '-' : name.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          softWrap: true, // Memungkinkan pindah baris
        ),
        Text(
          phone.isEmpty ? '-' : phone,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
      ],
    );
  }

  void _showFullDetail(BuildContext context, LandHistoryItemModel data) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Text(
                  "DETAIL RIWAYAT LAHAN",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _detailRow("1. Polisi Penggerak", data.policeName),
                    const Divider(),
                    _detailRow("2. Penanggung Jawab", data.picName),
                    const Divider(),
                    _detailRow(
                      "3. Luas Lahan",
                      "${data.landArea.toStringAsFixed(2)} Ha",
                    ),
                    const Divider(),
                    _detailRow("4. Tanam", "-"),
                    const Divider(),
                    _detailRow("5. Est. Panen", "-"),
                    const Divider(),
                    _detailRow("6. Panen", "-"),
                    const Divider(),
                    _detailRow("7. Hasil", "-"),
                    const Divider(),
                    _detailRow("8. Serapan", "-"),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          "Tutup",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 11),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value.isEmpty || value == "null" ? "-" : value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
