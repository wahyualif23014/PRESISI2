import 'package:flutter/material.dart';
// 1. IMPORT DATA & MODEL
import 'package:sdmapp/features/admin/main_data/units/data/unit_model.dart';
import 'package:sdmapp/features/admin/main_data/units/data/unit_repository.dart'; // Pastikan path ini benar

// 2. IMPORT WIDGETS
import '../widgets/unit_search_bar.dart';
import '../widgets/action_buttons.dart';
import '../widgets/unit_item_card.dart';

class UnitsPage extends StatefulWidget {
  const UnitsPage({super.key});

  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<UnitModel> _sortedData = [];
  
  bool _isExpanded = true; // Default terbuka agar data terlihat semua

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  // Fungsi untuk mengurutkan data: Polres paling atas, sisanya Polsek urut A-Z
  void _prepareData() {
    List<UnitModel> allData = List.from(dummyGresikUnits);
    
    // Ambil Polres (Induk)
    final polres = allData.where((u) => u.isPolres).toList();
    // Ambil Polsek (Anak) dan urutkan A-Z
    final polsek = allData.where((u) => !u.isPolres).toList();
    polsek.sort((a, b) => a.title.compareTo(b.title));

    // Gabungkan kembali
    setState(() {
      _sortedData = [...polres, ...polsek];
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final displayList = _isExpanded ? _sortedData : [_sortedData.first];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // ---------------------------------------
          // 1. BAGIAN HEADER
          // ---------------------------------------
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                UnitSearchBar(
                  controller: _searchController,
                  onChanged: (value) {
                    // TODO: Implementasi search nanti
                  },
                ),
                const SizedBox(height: 12),
                ActionButtons(onFilter: () {}),
              ],
            ),
          ),

          // ---------------------------------------
          // 2. BAGIAN INFO BANNER
          // ---------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey.shade200,
            child: Text(
              // Tampilkan jumlah data asli
              "TERDAPAT ${_sortedData.length} UNIT KESATUAN TERDATA", 
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),

          // ---------------------------------------
          // 3. BAGIAN LIST (DATA IMPLEMENTED)
          // ---------------------------------------
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: displayList.length, 
              separatorBuilder: (context, index) => 
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final unit = displayList[index];

                // Panggil Widget Item Card yang sudah kita buat
                Widget card = UnitItemCard(unit: unit);


                if (unit.isPolres) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Stack(
                      children: [
                        card,
                        // Ikon panah kecil di kanan sebagai indikator
                        Positioned(
                          right: 16,
                          top: 0,
                          bottom: 0,
                          child: Icon(
                            _isExpanded 
                                ? Icons.keyboard_arrow_up 
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  );
                }

                // Jika Polsek, tampilkan card biasa
                return card;
              },
            ),
          ),
        ],
      ),
    );
  }
}