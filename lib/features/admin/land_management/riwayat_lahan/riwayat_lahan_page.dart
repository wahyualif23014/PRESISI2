import 'package:flutter/material.dart';
// Ganti path import sesuai struktur project Anda
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/presentation/widgets/search_kelola_lahan.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/models/lahan_history_model.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/repos/lahan_history_repos.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/presentation/widget/filter_riwayat.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/presentation/widget/history_list.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/presentation/widget/history_summary.dart';


class RiwayatKelolaLahanPage extends StatefulWidget {
  const RiwayatKelolaLahanPage({super.key});

  @override
  State<RiwayatKelolaLahanPage> createState() => _RiwayatKelolaLahanPageState();
}

class _RiwayatKelolaLahanPageState extends State<RiwayatKelolaLahanPage> {
  final TextEditingController _searchController = TextEditingController();
  final LandHistoryRepository _repo = LandHistoryRepository();

  // State Data
  LandHistorySummaryModel? _summaryData;
  List<LandHistoryItemModel> _listData = [];
  
  // Data yang sudah diproses (Grouped) untuk UI
  Map<String, List<LandHistoryItemModel>> _groupedData = {};
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      // Optimasi: Fetch data secara paralel (async concurrent)
      final results = await Future.wait([
        _repo.getSummaryStats(),
        _repo.getHistoryList(),
      ]);

      if (!mounted) return;

      final summary = results[0] as LandHistorySummaryModel;
      final list = results[1] as List<LandHistoryItemModel>;

      setState(() {
        _summaryData = summary;
        _listData = list;
        // Proses grouping dilakukan sekali saat data diterima, bukan saat build
        _groupedData = _groupDataByRegion(list);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading history: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Pure Function untuk grouping data
  Map<String, List<LandHistoryItemModel>> _groupDataByRegion(List<LandHistoryItemModel> data) {
    final Map<String, List<LandHistoryItemModel>> grouped = {};
    for (var item in data) {
      grouped.putIfAbsent(item.regionGroup, () => []).add(item);
    }
    return grouped;
  }

  // Logic untuk menampilkan Filter Dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterriwayatDialog(
          onApply: (keyword, selectedFilters) {
            debugPrint("Filter Applied -> Keyword: $keyword, Categories: $selectedFilters");
            // TODO: Panggil fungsi filter data lokal atau fetch API ulang dengan parameter filter
            // _applyFilter(keyword, selectedFilters);
          },
          onReset: () {
            debugPrint("Filter Reset");
            // _fetchData(); // Reload data awal
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. SEARCH BAR & FILTER
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchKelolaLahan(
              controller: _searchController,
              onChanged: (val) {
                 // Debounce logic bisa ditambahkan disini
                 debugPrint("Searching: $val");
              },
              onFilterTap: _showFilterDialog, // Integrasi Dialog
            ),
          ),

          // 2. KONTEN
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // A. SUMMARY STATS
        if (_summaryData != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: HistorySummary(data: _summaryData!),
          ),
        
        const SizedBox(height: 16),

        // B. HEADER TABLE (Extracted Widget recommended for clean code)
        const _HistoryTableHeader(),

        // C. LIST DATA
        if (_listData.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Center(child: Text("Tidak ada riwayat data")),
          )
        else
          ..._groupedData.entries.map((entry) {
            return HistoryRegionExpansionTile(
              title: entry.key,
              items: entry.value,
            );
          }),
      ],
    );
  }
}

// Extracted Header Widget agar kode utama lebih bersih
class _HistoryTableHeader extends StatelessWidget {
  const _HistoryTableHeader();

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text("POLISI PENGGERAK", style: _headerStyle)),
          Expanded(flex: 3, child: Text("PJ", style: _headerStyle)),
          Expanded(flex: 2, child: Center(child: Text("LUAS (HA)", style: _headerStyle))),
          Expanded(flex: 2, child: Center(child: Text("VALIDASI", style: _headerStyle))),
          Expanded(flex: 1, child: Center(child: Text("AKSI", style: _headerStyle))),
        ],
      ),
    );
  }
}