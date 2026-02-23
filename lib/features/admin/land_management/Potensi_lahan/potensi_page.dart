import 'dart:async';
import 'package:flutter/material.dart';
import 'data/model/land_potential_model.dart';
import 'data/service/land_potential_service.dart';
import 'presentation/widget/add_land_data_page.dart';
import 'presentation/widget/land_filter_dialog.dart';
import 'presentation/widget/land_potential_group.dart';
import 'presentation/widget/land_potential_toolbar.dart';
import 'presentation/widget/land_summary_widget.dart';
import 'presentation/widget/no_land_potential_widget.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final LandPotentialService _service = LandPotentialService();

  // REFAKTOR: Tambahkan GlobalKey untuk memicu update widget summary
  final GlobalKey<LandSummaryWidgetState> _summaryKey = GlobalKey();
  final GlobalKey<NoLandPotentialWidgetState> _noLandKey = GlobalKey();

  bool _isLoading = true;
  bool _isError = false;
  Map<String, List<LandPotentialModel>> _groupedData = {};
  String _currentSearch = "";
  Map<String, String>? _activeFilters;
  int _currentPage = 1;
  final int _limitPerPage = 50;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // REFAKTOR: Fungsi untuk menyegarkan angka-angka summary
  void _refreshSummaries() {
    _summaryKey.currentState?.fetchSummaryData();
    _noLandKey.currentState?.fetchData();
  }

  Future<void> _fetchData({
    String keyword = "",
    Map<String, String>? filters,
  }) async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    if (filters != null) _activeFilters = filters;
    if (keyword.isNotEmpty) _currentSearch = keyword;

    try {
      final List<LandPotentialModel> data = await _service.fetchLandData(
        search: keyword.isNotEmpty ? keyword : _currentSearch,
        polres: _activeFilters?['polres'],
        polsek: _activeFilters?['polsek'],
        page: _currentPage,
        limit: _limitPerPage,
      );

      Map<String, List<LandPotentialModel>> grouped = {};
      for (var item in data) {
        String fullRegion =
            "KAB. ${item.kabupaten} KEC. ${item.kecamatan} DESA ${item.desa}";
        if (!grouped.containsKey(fullRegion)) grouped[fullRegion] = [];
        grouped[fullRegion]!.add(item);
      }

      if (mounted) {
        setState(() {
          _groupedData = grouped;
          _isLoading = false;
        });
        // REFAKTOR: Panggil update summary setiap kali data list berubah
        _refreshSummaries();
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _isError = true;
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          LandPotentialToolbar(
            onSearchChanged: _onSearch,
            onFilterTap: _onFilterTap,
            onAddTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const AddLandDataPage()),
                ).then((_) => _fetchData()),
          ),
          Expanded(
            child: ListView(
              children: [
                // REFAKTOR: Pasang Key pada widget summary
                LandSummaryWidget(key: _summaryKey),
                NoLandPotentialWidget(key: _noLandKey),

                _buildHeaderPembatas("DAFTAR POTENSI LAHAN"),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ..._groupedData.entries.map(
                    (entry) => KabupatenExpansionTile(
                      kabupatenName: entry.key,
                      itemsInKabupaten: entry.value,
                      onEdit:
                          (item) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => AddLandDataPage(editData: item),
                            ),
                          ).then((_) => _fetchData()),
                      onDelete: (item) => _confirmDelete(item),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSearch(String val) {
    _currentPage = 1;
    _fetchData(keyword: val);
  }

  void _onFilterTap() {
    showDialog(
      context: context,
      builder:
          (c) => LandFilterDialog(
            onApply: (f) {
              _currentPage = 1;
              _fetchData(filters: f);
            },
            onReset: () {
              _activeFilters = null;
              _fetchData();
            },
          ),
    );
  }

  void _confirmDelete(LandPotentialModel item) {
    showDialog(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text("Hapus Data"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(c);
                  if (await _service.deleteLandData(item.id)) _fetchData();
                },
                child: const Text("Hapus"),
              ),
            ],
          ),
    );
  }

  Widget _buildHeaderPembatas(String title) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.only(left: 12),
    decoration: const BoxDecoration(
      border: Border(left: BorderSide(color: Colors.black, width: 4)),
    ),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}
