import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';

// =========================================================
// LEVEL 1: GROUP WILAYAH (KAB/KEC/DESA) - UNGU TUA
// =========================================================
class RegionExpansionTile extends StatelessWidget {
  final String title;
  final List<LandManagementItemModel> items;

  const RegionExpansionTile({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Grouping lagi berdasarkan Sub-Region (Dusun)
    Map<String, List<LandManagementItemModel>> groupedByDusun = {};
    for (var item in items) {
      if (!groupedByDusun.containsKey(item.subRegionGroup)) {
        groupedByDusun[item.subRegionGroup] = [];
      }
      groupedByDusun[item.subRegionGroup]!.add(item);
    }

    return ExpansionTile(
      initiallyExpanded: true,
      collapsedBackgroundColor: const Color(0xFFC5CAE9), // Ungu Tua (Indigo 100)
      backgroundColor: const Color(0xFFC5CAE9),
      shape: const Border(), // Hilangkan garis border default
      textColor: Colors.black,
      iconColor: Colors.black,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
      ),
      children: groupedByDusun.entries.map((entry) {
        return SubRegionExpansionTile(
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
class SubRegionExpansionTile extends StatelessWidget {
  final String title;
  final List<LandManagementItemModel> items;

  const SubRegionExpansionTile({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      collapsedBackgroundColor: const Color(0xFFE8EAF6), // Ungu Muda (Indigo 50)
      backgroundColor: const Color(0xFFE8EAF6),
      shape: const Border(),
      tilePadding: const EdgeInsets.only(left: 20, right: 16), // Menjorok ke dalam
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      ),
      children: items.map((item) => LandManagementRow(item: item)).toList(),
    );
  }
}

// =========================================================
// LEVEL 3: DATA ITEM ROW
// =========================================================
class LandManagementRow extends StatelessWidget {
  final LandManagementItemModel item;

  const LandManagementRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 1), // Garis pemisah tipis
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
          
          // 3. LUAS (Flex 1)
          Expanded(
            flex: 1,
            child: Text(
              item.landArea.toString(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // 4. VALIDASI / STATUS (Flex 2)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
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