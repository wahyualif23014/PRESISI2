import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/land_management/kelola_lahan/presentation/widgets/search_kelola_lahan.dart';
import 'package:sdmapp/features/admin/land_management/riwayat_lahan/data/models/lahan_history_model.dart';
import 'package:sdmapp/features/admin/land_management/riwayat_lahan/data/repos/lahan_history_repos.dart';
import 'package:sdmapp/features/admin/land_management/riwayat_lahan/presentation/widget/history_list.dart';
import 'package:sdmapp/features/admin/land_management/riwayat_lahan/presentation/widget/history_summary.dart';


class RiwayatKelolaLahanPage extends StatefulWidget {
  const RiwayatKelolaLahanPage({super.key});

  @override
  State<RiwayatKelolaLahanPage> createState() => _RiwayatKelolaLahanPageState();
}

class _RiwayatKelolaLahanPageState extends State<RiwayatKelolaLahanPage> {
  // Controller Search
  final TextEditingController _searchController = TextEditingController();
  
  // Repository
  final LandHistoryRepository _repo = LandHistoryRepository();

  // State Data
  LandHistorySummaryModel? _summaryData;
  List<LandHistoryItemModel> _listData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fungsi Ambil Data Dummy dari Repo
  Future<void> _fetchData() async {
    try {
      final summary = await _repo.getSummaryStats();
      final list = await _repo.getHistoryList();
      
      if (mounted) {
        setState(() {
          _summaryData = summary;
          _listData = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    Map<String, List<LandHistoryItemModel>> groupedByRegion = {};
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
          // ===========================================
          // 1. SEARCH BAR & FILTER
          // ===========================================
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchKelolaLahan(
              controller: _searchController,
              onChanged: (val) {
                // TODO: Implementasi logika filter list di sini
                print("Searching: $val");
              },
              onFilterTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Filter ditekan")),
                );
              },
            ),
          ),

          // ===========================================
          // 2. KONTEN SCROLLABLE
          // ===========================================
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      // A. SUMMARY STATS (KOTAK ATAS)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: HistorySummary(data: _summaryData),
                      ),
                      
                      const SizedBox(height: 16),

                      // B. HEADER TABLE (STATIS)
                      // Flex di sini HARUS SAMA dengan HistoryRow di history_list.dart
                      Container(
                        color: Colors.grey.shade200,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: const Row(
                          children: [
                            Expanded(flex: 3, child: Text("POLISI PENGGERAK", style: _headerStyle)),
                            Expanded(flex: 3, child: Text("PJ", style: _headerStyle)),
                            // Flex 2 agar muat teks panjang header jika ada
                            Expanded(flex: 2, child: Center(child: Text("LUAS (HA)", style: _headerStyle))),
                            Expanded(flex: 2, child: Center(child: Text("VALIDASI", style: _headerStyle))),
                            Expanded(flex: 1, child: Center(child: Text("AKSI", style: _headerStyle))),
                          ],
                        ),
                      ),

                      // C. LIST DATA (GROUPED)
                      if (_listData.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(child: Text("Tidak ada riwayat data")),
                        )
                      else
                        // Render Grouping Wilayah (Ungu Tua)
                        ...groupedByRegion.entries.map((entry) {
                          return HistoryRegionExpansionTile(
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

// Style Teks Header Table
const TextStyle _headerStyle = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);