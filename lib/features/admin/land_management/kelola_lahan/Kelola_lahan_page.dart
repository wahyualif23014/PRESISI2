import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';
import 'package:sdmapp/features/admin/land_management/kelola_lahan/data/repos/kelola_repo.dart';
import 'package:sdmapp/features/admin/land_management/kelola_lahan/presentation/widgets/kelola_list.dart';
import 'package:sdmapp/features/admin/land_management/kelola_lahan/presentation/widgets/kelola_summary.dart';
import 'package:sdmapp/features/admin/land_management/kelola_lahan/presentation/widgets/search_kelola_lahan.dart';

class KelolaLahanPage extends StatefulWidget {
  const KelolaLahanPage({super.key});

  @override
  State<KelolaLahanPage> createState() => _KelolaLahanPageState();
}

class _KelolaLahanPageState extends State<KelolaLahanPage> {
  final LandManagementRepository _repo = LandManagementRepository();
  final TextEditingController _searchController = TextEditingController();

  LandManagementSummaryModel? _summaryData;
  List<LandManagementItemModel> _listData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final summary = await _repo.getSummaryStats();
      final list = await _repo.getLandManagementList();

      if (mounted) {
        setState(() {
          _summaryData = summary;
          _listData = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // LOGIC GROUPING UTAMA (Level 1: Wilayah)
    Map<String, List<LandManagementItemModel>> groupedByRegion = {};
    for (var item in _listData) {
      if (!groupedByRegion.containsKey(item.regionGroup)) {
        groupedByRegion[item.regionGroup] = [];
      }
      groupedByRegion[item.regionGroup]!.add(item);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. SEARCH & FILTER
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchKelolaLahan(
              controller: _searchController, 
              onChanged: (String query) {
                // Logika pencarian Anda di sini
                print("Sedang mencari: $query");
                // Contoh: _runSearch(query);
              },
              onFilterTap: () {
                // Logika ketika tombol filter ditekan
                print("Tombol Filter ditekan");
              },
            ),
          ),

          // 2. SCROLLABLE CONTENT
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                      padding: const EdgeInsets.only(bottom: 80),
                      children: [
                        // A. SUMMARY STATS (KOTAK ATAS)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: LandManagementSummary(data: _summaryData),
                        ),

                        const SizedBox(height: 16),

                        // B. HEADER TABLE
                        Container(
                          color: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "POLISI PENGGERAK",
                                  style: _headerStyle,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text("PJ", style: _headerStyle),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text("LUAS (HA)", style: _headerStyle),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text("VALIDASI", style: _headerStyle),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text("AKSI", style: _headerStyle),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // C. LIST DATA (GROUPED)
                        if (_listData.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Center(child: Text("Tidak ada data")),
                          )
                        else
                          ...groupedByRegion.entries.map((entry) {
                            return RegionExpansionTile(
                              title: entry.key,
                              items: entry.value,
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
  fontSize: 9,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);
