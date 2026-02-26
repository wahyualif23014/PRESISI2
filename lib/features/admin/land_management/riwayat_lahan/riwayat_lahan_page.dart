import 'dart:async';
import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/models/lahan_history_model.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/repos/lahan_history_repos.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/presentation/widget/filter_riwayat.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/presentation/widget/history_list.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/presentation/widget/history_summary.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/presentation/widget/search_lahan_history.dart';

class RiwayatKelolaLahanPage extends StatefulWidget {
  const RiwayatKelolaLahanPage({super.key});

  @override
  State<RiwayatKelolaLahanPage> createState() => _RiwayatKelolaLahanPageState();
}

class _RiwayatKelolaLahanPageState extends State<RiwayatKelolaLahanPage> {
  final TextEditingController _searchController = TextEditingController();
  final LandHistoryRepository _repo = LandHistoryRepository();

  Timer? _debounce;
  LandHistorySummaryModel? _summaryData;
  List<LandHistoryItemModel> _listData = [];
  Map<String, List<LandHistoryItemModel>> _groupedData = {};

  bool _isLoading = true;
  Map<String, String>? _activeFilters;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // riwayat_lahan_page.dart

  Future<void> _fetchData({
    String keyword = "",
    Map<String, String>? filters,
  }) async {
    // Jika ada filter baru dari dialog, simpan ke state global page
    if (filters != null) _activeFilters = filters;

    setState(() => _isLoading = true);

    try {
      // Selalu kirim keyword pencarian DAN filter aktif saat ini
      final list = await _repo.getHistoryList(
        keyword: keyword.isEmpty ? _searchController.text : keyword,
        filters: _activeFilters,
      );

      if (!mounted) return;

      setState(() {
        _listData = list;
        _groupedData = _groupDataByRegion(list);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, List<LandHistoryItemModel>> _groupDataByRegion(
    List<LandHistoryItemModel> data,
  ) {
    final Map<String, List<LandHistoryItemModel>> grouped = {};
    for (var item in data) {
      grouped.putIfAbsent(item.regionGroup, () => []).add(item);
    }
    return grouped;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterriwayatDialog(
          onApply: (filtersFromDialog) {
            _fetchData(
              keyword: _searchController.text,
              filters: filtersFromDialog,
            );
          },
          onReset: () {
            _searchController.clear();
            _activeFilters = null;
            _fetchData();
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchLahanHistory(
              controller: _searchController,
              onChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  _fetchData(keyword: val);
                });
              },
              onFilterTap: _showFilterDialog,
            ),
          ),
          Expanded(
            child:
                _isLoading
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
        if (_summaryData != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: HistorySummary(data: _summaryData!),
          ),
        const SizedBox(height: 16),
        _buildTableHeader(),
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

  Widget _buildTableHeader() {
    return Container(
      color: Colors.deepPurple,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: const Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "POLISI PENGGERAK",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              "PJ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "VALIDASI",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "DETAIL",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
