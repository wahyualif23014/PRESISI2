import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/data/models/unit_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/data/repos/unit_repository.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/presentation/widgets/unit_filter_dialog.dart';

import 'presentation/widgets/unit_search_bar.dart';
import 'presentation/widgets/unit_item_card.dart';

class UnitsPage extends StatefulWidget {
  const UnitsPage({super.key});

  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<UnitRegion> _allData;
  late List<UnitRegion> _filteredList;

  @override
  void initState() {
    super.initState();
    _allData = allRegionsData;
    _filteredList = _allData;
  }

  //
  void _runSearch(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        _filteredList = _allData;
      } else {
        List<UnitRegion> results = [];

        for (var region in _allData) {
          bool parentMatches = region.polres.title.toLowerCase().contains(
            keyword.toLowerCase(),
          );

          List<UnitModel> matchingChildren =
              region.polseks.where((child) {
                return child.title.toLowerCase().contains(
                  keyword.toLowerCase(),
                );
              }).toList();

          if (parentMatches) {
            results.add(region);
          } else if (matchingChildren.isNotEmpty) {
            results.add(
              UnitRegion(
                polres: region.polres,
                polseks: matchingChildren,
                isExpanded: true,
              ),
            );
          }
        }

        _filteredList = results;
      }
    });
  }

  int _calculateTotalUnits() {
    int total = 0;
    for (var region in _filteredList) {
      total += 1; // Polres
      total += region.polseks.length; // Polsek
    }
    return total;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                UnitSearchFilter(
                  controller: _searchController,
                  onChanged: (val) => print("Search: $val"),
                  onFilterTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true, // Bisa ditutup dengan klik luar
                      builder: (BuildContext context) {
                        return UnitFilterDialog(
                          onApply: () {
                            // Tambahkan logika filtering Anda di sini
                            print("Filter Applied!");
                          },
                          onReset: () {
                            // Tambahkan logika reset data di sini
                            print("Filter Reset!");
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // ---------------------------------------
          // 2. BAGIAN INFO BANNER
          // ---------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Text(
              "DITEMUKAN ${_calculateTotalUnits()} UNIT KESATUAN",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          // ---------------------------------------
          // 3. BAGIAN LIST
          // ---------------------------------------
          Expanded(
            child:
                _filteredList.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _filteredList.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final region = _filteredList[index];

                        return Column(
                          children: [
                            // A. Parent (Polres)
                            UnitItemCard(
                              unit: region.polres,
                              isExpanded: region.isExpanded,
                              onExpandTap: () {
                                setState(() {
                                  region.isExpanded = !region.isExpanded;
                                });
                              },
                            ),
                            // B. Children (Polsek) - Loop List yang sudah difilter
                            if (region.isExpanded)
                              Column(
                                children:
                                    region.polseks.map((polsek) {
                                      return UnitItemCard(
                                        unit: polsek,
                                        isExpanded: false,
                                      );
                                    }).toList(),
                              ),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Widget tambahan jika pencarian 0 hasil
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Data tidak ditemukan",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
