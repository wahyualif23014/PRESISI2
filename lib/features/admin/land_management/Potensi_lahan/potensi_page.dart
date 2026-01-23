import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/data/model/land_potential_model.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/data/repos/land_potential_repository.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/presentation/widget/land_potential_group.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/presentation/widget/land_potential_toolbar.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/presentation/widget/land_summary_widget.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/presentation/widget/no_land_potential_widget.dart'; 

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _CropsPageState();
}

class _CropsPageState extends State<OverviewPage> {
  final LandPotentialRepository _repo = LandPotentialRepository();

  List<LandPotentialModel> _dataList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _repo.getLandPotentials();
      if (mounted) {
        setState(() {
          _dataList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<LandPotentialModel>> groupedByKabupaten = {};
    for (var item in _dataList) {
      if (!groupedByKabupaten.containsKey(item.kabupaten)) {
        groupedByKabupaten[item.kabupaten] = [];
      }
      groupedByKabupaten[item.kabupaten]!.add(item);
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // ============================================
          // 1. TOOLBAR (TETAP FIXED DI ATAS)
          // ============================================
          LandPotentialToolbar(
            onSearchChanged: (query) {
              print("Mencari: $query");
            },
            onFilterTap: () {
              print("Tombol Filter ditekan");
            },
            onAddTap: () {
              print("Tombol Tambah ditekan");
            },
          ),

          // ============================================
          // 2. SCROLLABLE AREA (Summary + Header + Data)
          // ============================================
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.only(bottom: 100), // Padding untuk BottomNav
                    children: [
                      // A. WIDGET SUMMARY (Sekarang ikut di-scroll)
                      const LandSummaryWidget(),
                      const NoLandPotentialWidget(),

                      Container(
                        color: Colors.grey.shade200,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text("POLISI PENGGERAK", style: _headerStyle),
                            ),
                            Expanded(flex: 2, child: Text("PJ", style: _headerStyle)),
                            Expanded(
                              flex: 3,
                              child: Center(child: Text("ALAMAT", style: _headerStyle)),
                            ),
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Text("VALIDASI / AKSI", style: _headerStyle),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // C. LIST DATA (GROUPED)
                      if (_dataList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              "Belum ada data potensi lahan",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...groupedByKabupaten.entries.map((entry) {
                          return KabupatenExpansionTile(
                            kabupatenName: entry.key,
                            itemsInKabupaten: entry.value,
                          );
                        }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.bold,
  color: Colors.black54,
);