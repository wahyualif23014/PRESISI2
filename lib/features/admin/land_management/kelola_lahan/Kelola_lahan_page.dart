import 'package:flutter/material.dart';
// Asumsi import model dan repo sudah benar
import 'package:sdmapp/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';
import 'package:sdmapp/features/admin/land_management/kelola_lahan/data/repos/kelola_repo.dart';
import 'package:sdmapp/features/admin/land_management/kelola_lahan/presentation/widgets/filter_lahan_dialog.dart';
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

  // State Data
  LandManagementSummaryModel? _summaryData;
  List<LandManagementItemModel> _listData = [];
  Map<String, List<LandManagementItemModel>> _groupedData = {};
  
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
    // Set loading jika perlu refresh ulang dari awal
    // setState(() => _isLoading = true); 
    
    try {
      // Menggunakan Future.wait untuk parallel request agar lebih cepat
      final results = await Future.wait([
        _repo.getSummaryStats(),
        _repo.getLandManagementList(),
      ]);

      if (!mounted) return;

      final summary = results[0] as LandManagementSummaryModel;
      final list = results[1] as List<LandManagementItemModel>;

      setState(() {
        _summaryData = summary;
        _listData = list;
        _processGrouping(list); // Grouping dilakukan HANYA saat data berubah
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Logic grouping dipisah agar method build tetap ringan
  void _processGrouping(List<LandManagementItemModel> data) {
    final Map<String, List<LandManagementItemModel>> tempGroup = {};
    for (var item in data) {
      tempGroup.putIfAbsent(item.regionGroup, () => []).add(item);
    }
    _groupedData = tempGroup;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterLahanDialog(
          onApply: (keyword, selectedFilters) {
            debugPrint("Filter Applied: $keyword, Filters: $selectedFilters");
          },
          onReset: () {
            debugPrint("Filter Reset");
            // Reset logika di sini
            // _fetchData(); 
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
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchKelolaLahan(
        controller: _searchController,
        onChanged: (String query) {
          // Debounce logic sebaiknya diterapkan di sini jika search hit API
          debugPrint("Searching: $query");
        },
        onFilterTap: _showFilterDialog, // Memanggil dialog filter
      ),
    );
  }

  Widget _buildContent() {
    if (_listData.isEmpty) {
      return const Center(child: Text("Tidak ada data"));
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (_summaryData != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LandManagementSummary(data: _summaryData!),
          ),
        const SizedBox(height: 16),
        _buildTableHeader(),
        ..._groupedData.entries.map((entry) {
          return RegionExpansionTile(
            title: entry.key,
            items: entry.value,
          );
        }),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HeaderCell("POLISI PENGGERAK")),
          Expanded(flex: 3, child: _HeaderCell("PJ")),
          Expanded(flex: 1, child: _HeaderCell("LUAS (HA)", align: TextAlign.center)),
          Expanded(flex: 2, child: _HeaderCell("VALIDASI", align: TextAlign.center)),
          Expanded(flex: 1, child: _HeaderCell("AKSI", align: TextAlign.center)),
        ],
      ),
    );
  }
}

// Extracted widget untuk Header Cell agar code lebih rapi dan DRY
class _HeaderCell extends StatelessWidget {
  final String text;
  final TextAlign align;

  const _HeaderCell(this.text, {this.align = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}