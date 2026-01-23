import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/data/model/land_potential_model.dart';
import 'land_potential_card.dart';

class KabupatenExpansionTile extends StatelessWidget {
  final String kabupatenName;
  final List<LandPotentialModel> itemsInKabupaten;

  const KabupatenExpansionTile({
    super.key,
    required this.kabupatenName,
    required this.itemsInKabupaten,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, List<LandPotentialModel>> groupedByKecamatan = {};
    for (var item in itemsInKabupaten) {
      if (!groupedByKecamatan.containsKey(item.kecamatanDesa)) {
        groupedByKecamatan[item.kecamatanDesa] = [];
      }
      groupedByKecamatan[item.kecamatanDesa]!.add(item);
    }

    return ExpansionTile(
      initiallyExpanded: true, // Default terbuka
      collapsedBackgroundColor: const Color(0xFF9FA8DA), // Warna saat tertutup
      backgroundColor: const Color(0xFF9FA8DA), // Warna Header Ungu Tua (Indigo 200)
      title: Text(
        kabupatenName,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
      ),
      children: groupedByKecamatan.entries.map((entry) {
        return KecamatanExpansionTile(
          kecamatanName: entry.key,
          items: entry.value,
        );
      }).toList(),
    );
  }
}

class KecamatanExpansionTile extends StatelessWidget {
  final String kecamatanName;
  final List<LandPotentialModel> items;

  const KecamatanExpansionTile({
    super.key,
    required this.kecamatanName,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true, // Default terbuka
      collapsedBackgroundColor: const Color(0xFFC5CAE9), 
      backgroundColor: const Color(0xFFC5CAE9), // Warna Header Ungu Muda (Indigo 100)
      title: Text(
        kecamatanName,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
      ),
      shape: const Border(), 
      children: items.map((data) => LandPotentialCard(data: data)).toList(),
    );
  }
}