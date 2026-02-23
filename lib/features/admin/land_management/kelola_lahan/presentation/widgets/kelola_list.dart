import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';

class KelolaRegionExpansionGroup extends StatelessWidget {
  final String title;
  final List<LandManagementItemModel> items;
  const KelolaRegionExpansionGroup({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ExpansionTile(
        initiallyExpanded: true,
        collapsedBackgroundColor: const Color(0xFF9FA8DA).withOpacity(0.5),
        backgroundColor: const Color(0xFFC5CAE9).withOpacity(0.5),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        children:
            items.map((data) => KelolaItemDetailCard(item: data)).toList(),
      ),
    );
  }
}

class KelolaItemDetailCard extends StatelessWidget {
  final LandManagementItemModel item;
  const KelolaItemDetailCard({super.key, required this.item});

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              "DETAIL LAHAN",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detailRow("Polisi Penggerak", item.policeName),
                  _detailRow("Penanggung Jawab", item.picName),
                  _detailRow("Luas (Ha)", "${item.luasTanam}"),
                  _detailRow("Est. Panen", item.estPanen),
                  _detailRow("Panen (Ha)", "${item.hasilPanen}"),
                  _detailRow("Serapan (Ton)", "${item.serapan}"),
                  _detailRow("Validasi", item.status),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("TUTUP"),
              ),
            ],
          ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          const Text(" : "),
          Expanded(
            flex: 6,
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid =
        item.status == 'TERVALIDASI' || item.status == 'VALIDATED';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // POLISI
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Polisi Pengerak",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            item.policeName,
                            style: _nameStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.policePhone,
                            style: _subStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // PENANGGUNG JAWAB
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Penanggung Jawab",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.picName,
                            style: _nameStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.picPhone,
                            style: _subStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: isValid ? Colors.green : Colors.orange,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        color: isValid ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 28,
                  child: ElevatedButton(
                    onPressed: () => _showDetailDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "VIEW DETAIL",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 8,
      color: Colors.grey,
      fontWeight: FontWeight.bold,
    ),
  );
  TextStyle _nameStyle() => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );
  TextStyle _subStyle() => const TextStyle(fontSize: 9, color: Colors.black54);
}
