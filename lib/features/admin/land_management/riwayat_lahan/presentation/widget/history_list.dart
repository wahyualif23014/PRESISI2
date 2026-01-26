import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/land_management/riwayat_lahan/data/models/lahan_history_model.dart';

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
    // Grouping berdasarkan Sub-Region (Dusun)
    Map<String, List<LandHistoryItemModel>> groupedByDusun = {};
    for (var item in items) {
      if (!groupedByDusun.containsKey(item.subRegionGroup)) {
        groupedByDusun[item.subRegionGroup] = [];
      }
      groupedByDusun[item.subRegionGroup]!.add(item);
    }

    return ExpansionTile(
      initiallyExpanded: true,
      collapsedBackgroundColor: const Color(0xFFC5CAE9), // Ungu Tua
      backgroundColor: const Color(0xFFC5CAE9),
      shape: const Border(),
      textColor: Colors.black,
      iconColor: Colors.black,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
      ),
      children: groupedByDusun.entries.map((entry) {
        return HistorySubRegionExpansionTile(
          title: entry.key,
          items: entry.value,
        );
      }).toList(),
    );
  }
}

// =========================================================
// LEVEL 2: GROUP DUSUN - UNGU MUDA (MENJOROK)
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
    return ExpansionTile(
      initiallyExpanded: true,
      collapsedBackgroundColor: const Color(0xFFE8EAF6), // Ungu Muda
      backgroundColor: const Color(0xFFE8EAF6),
      shape: const Border(),
      tilePadding: const EdgeInsets.only(left: 20, right: 16),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      ),
      children: items.map((item) => HistoryRow(item: item)).toList(),
    );
  }
}

// =========================================================
// LEVEL 3: DATA ITEM ROW (KHUSUS RIWAYAT)
// =========================================================
class HistoryRow extends StatelessWidget {
  final LandHistoryItemModel item;

  const HistoryRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. POLISI PENGGERAK (Flex 3)
          Expanded(
            flex: 3,
            child: _buildPersonInfo(item.policeName, item.policePhone),
          ),
          
          // 2. PJ (Flex 3)
          Expanded(
            flex: 3,
            child: _buildPersonInfo(item.picName, item.picPhone),
          ),
          
          // 3. LUAS (Flex 2) - KHUSUS RIWAYAT ADA KATEGORI LAHAN
          Expanded(
            flex: 2, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.landArea.toStringAsFixed(2), // Format 2 desimal (3.50)
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  item.landCategory, // "POKTAN BINAAN POLRI"
                  style: const TextStyle(fontSize: 7, color: Colors.grey, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 4. VALIDASI / STATUS (Flex 2)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Color(int.parse(item.statusColor.replaceAll('#', '0xFF'))),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                item.status,
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // 5. AKSI (Flex 1)
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {},
              child: const Icon(Icons.remove_red_eye_outlined, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonInfo(String name, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          phone,
          style: const TextStyle(fontSize: 8, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}