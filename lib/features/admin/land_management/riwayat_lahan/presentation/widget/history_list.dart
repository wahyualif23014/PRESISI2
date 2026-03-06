import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/models/lahan_history_model.dart';

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

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      child: ExpansionTile(
        initiallyExpanded: true,
        collapsedBackgroundColor: const Color(0xFF9FA8DA),
        backgroundColor: const Color(0xFFC5CAE9),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        iconColor: Colors.black54,
        collapsedIconColor: Colors.black54,
        children: groupedByDusun.entries.map((entry) {
          return HistorySubRegionExpansionTile(
            title: entry.key,
            items: entry.value,
          );
        }).toList(),
      ),
    );
  }
}

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
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.isEmpty || title == '-'
                        ? 'ALAMAT TIDAK TERDATA'
                        : title.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Total: ${totalLuas.toStringAsFixed(2)} Ha",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color(0xFF1A237E),
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

class HistoryRow extends StatelessWidget {
  final LandHistoryItemModel item;

  const HistoryRow({super.key, required this.item});

  Color _getStatusColor(String colorCode) {
    try {
      if (colorCode.isNotEmpty) {
        return Color(int.parse(colorCode.replaceAll('#', '0xFF')));
      }
    } catch (_) {}
    return Colors.grey;
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A237E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.assignment, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        "DETAIL RIWAYAT LAHAN",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection(
                          "Data Riwayat Lahan",
                          Icons.history,
                          [
                            _dataRow("Polisi Penggerak", item.policeName),
                            _dataRow("Penanggung Jawab", item.picName),
                            _dataRow("Luas (Ha)", "${item.landArea} Ha"),
                            _dataRow("Tanam (Ha)", "${item.tanamArea} Ha"),
                            _dataRow("Est. Panen", item.estPanen),
                            _dataRow("Panen (Ha)", "${item.panenArea} Ha"),
                            _dataRow("Panen (Ton)", "${item.panenTon} Ton"),
                            _dataRow("Serapan (Ton)", "${item.serapanTon} Ton"),
                            _dataRow("Validasi", item.status, isLast: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "TUTUP",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1A237E)),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A237E),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _dataRow(String label, String val, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                " : ",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Expanded(
                flex: 6,
                child: Text(
                  val.trim().isEmpty ? "-" : val,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 6),
            Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLabel("POLISI PENGGERAK"),
                _buildName(
                  item.policeName.isNotEmpty ? item.policeName : "-",
                ),
                const SizedBox(height: 2),
                _buildPhone(item.policePhone),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLabel("PENANGGUNG JAWAB"),
                _buildName(item.picName.isNotEmpty ? item.picName : "-"),
                const SizedBox(height: 2),
                _buildPhone(item.picPhone),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: _getStatusColor(item.statusColor),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status.replaceAll(' ', '\n'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _getStatusColor(item.statusColor),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: InkWell(
                onTap: () => _showDetail(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.visibility, color: Colors.blue, size: 22),
                      const SizedBox(height: 4),
                      const Text(
                        "Detail",
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _buildName(String text) => Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

  Widget _buildPhone(String text) => Text(
        text.isEmpty ? "-" : text,
        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
      );
}