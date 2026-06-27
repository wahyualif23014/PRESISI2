import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
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
    final statusColor = _getStatusColor(item.statusColor);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.subRegionGroup.isEmpty || item.subRegionGroup == '-'
                          ? 'DUSUN TIDAK TERDATA'
                          : item.subRegionGroup.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A237E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: Colors.grey.shade100),
              const SizedBox(height: 8),

              // Body
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("POLISI PENGGERAK"),
                        const SizedBox(height: 2),
                        _buildName(item.policeName.isNotEmpty ? item.policeName : "-"),
                        _buildPhone(item.policePhone),
                        const SizedBox(height: 6),
                        _buildLabel("PENANGGUNG JAWAB"),
                        const SizedBox(height: 2),
                        _buildName(item.picName.isNotEmpty ? item.picName : "-"),
                        _buildPhone(item.picPhone),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("DETAIL LUAS"),
                        const SizedBox(height: 2),
                        Text(
                          "Lahan: ${item.landArea} Ha",
                          style: const TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                        Text(
                          "Tanam: ${item.tanamArea} Ha",
                          style: const TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        _buildLabel("HASIL PANEN & SERAPAN"),
                        const SizedBox(height: 2),
                        Text(
                          "Panen: ${item.panenTon} Ton",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                        ),
                        Text(
                          "Serapan: ${item.serapanTon} Ton",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Footer
              _buildActionFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Builder(builder: (context) {
        final auth = context.watch<AuthProvider>();
        final isPolsek = (auth.user?.tingkatDetail?.nama ?? '').toUpperCase().contains('POLSEK');
        final isRejected = item.status.toLowerCase().contains('tolak') || item.status == '2';
        final canEditOrDelete = !isPolsek || isRejected;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onPressed: () => _showDetail(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_outlined, size: 12),
                  SizedBox(width: 4),
                  Text("Detail", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (canEditOrDelete)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 16, color: Colors.grey),
                padding: EdgeInsets.zero,
                onSelected: (val) {
                  if (val == 'edit') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fitur Edit Panen sedang dalam pengembangan backend")),
                    );
                  } else if (val == 'delete') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fitur Hapus Panen sedang dalam pengembangan backend")),
                    );
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text("Edit", style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_outlined, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Hapus", style: TextStyle(fontSize: 11, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        );
      }),
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
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

  Widget _buildPhone(String text) => Text(
        text.isEmpty ? "-" : text,
        style: TextStyle(fontSize: 9, color: Colors.grey[600]),
      );
}