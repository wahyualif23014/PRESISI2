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
  Map<String, List<LandHistoryItemModel>> _groupedData = {};

  bool _isLoading = true;
  bool _isError = false;
  String _currentSearch = "";
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

  Future<void> _fetchData({
    String keyword = "",
    Map<String, String>? filters,
  }) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _isError = false;
    });

    if (filters != null) _activeFilters = filters;
    if (keyword.isNotEmpty) _currentSearch = keyword;

    try {
      // Mengambil data list dan summary dari repository
      final list = await _repo.getHistoryList(
        keyword: keyword.isNotEmpty ? keyword : _currentSearch,
        filters: _activeFilters,
      );

      final summary = await _repo.getSummaryStats(); // Mengambil data summary

      if (!mounted) return;

      Map<String, List<LandHistoryItemModel>> grouped = {};

      if (list.isEmpty) {
        setState(() {
          _groupedData = {};
          _summaryData = summary;
          _isLoading = false;
        });
      } else {
        for (var item in list) {
          grouped.putIfAbsent(item.regionGroup, () => []).add(item);
        }

        setState(() {
          _groupedData = grouped;
          _summaryData = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error RiwayatKelolaLahanPage Fetch: $e");
      if (mounted) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _onSearch(String val) {
    _currentSearch = val;
    _fetchData(keyword: val);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FilterriwayatDialog(
          onApply: (filtersFromDialog) {
            _fetchData(filters: filtersFromDialog);
          },
          onReset: () {
            _searchController.clear();
            _activeFilters = null;
            _currentSearch = "";
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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: SearchLahanHistory(
              controller: _searchController,
              onChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  _onSearch(val);
                });
              },
              onFilterTap: _showFilterDialog,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchData(),
              color: const Color(0xFF1A237E),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80, top: 8),
                children: [
                  if (_summaryData != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: HistorySummary(data: _summaryData!),
                    ),

                  _buildHeaderPembatas("DAFTAR RIWAYAT LAHAN"),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(80),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    )
                  else if (_isError)
                    _buildErrorState()
                  else if (_groupedData.isEmpty)
                    _buildEmptyState()
                  else
                    ..._groupedData.entries.map((entry) {
                      return HistoryRegionExpansionTile(
                        title: entry.key,
                        items: entry.value,
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text("🔍", style: TextStyle(fontSize: 50)),
          const SizedBox(height: 16),
          const Text(
            "Data riwayat tidak ditemukan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Text(
            "Coba ubah filter atau kata kunci pencarian kamu",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          TextButton(
            onPressed: () {
              _activeFilters = null;
              _currentSearch = "";
              _searchController.clear();
              _fetchData();
            },
            child: const Text(
              "Reset Filter",
              style: TextStyle(color: Color(0xFF1A237E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            const Text(
              "Gagal memuat data riwayat",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => _fetchData(),
              child: const Text(
                "Coba Lagi",
                style: TextStyle(color: Color(0xFF1A237E)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderPembatas(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Colors.black, width: 4)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.black,
        ),
      ),
    );
  }
}
