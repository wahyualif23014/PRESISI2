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

  final GlobalKey<LandSummaryWidgetState> _summaryKey = GlobalKey();
  final GlobalKey<NoLandPotentialWidgetState> _noLandKey = GlobalKey();

  bool _isLoading = true;
  bool _isError = false;
  Map<String, List<LandPotentialModel>> _groupedData = {};
  String _currentSearch = "";
  Map<String, String>? _activeFilters;
  int _currentPage = 1;
  final int _limitPerPage = 150;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _refreshSummaries() {
    _summaryKey.currentState?.fetchSummaryData();
    _noLandKey.currentState?.fetchData();
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
      String? polresVal = _activeFilters?['polres'];
      String? polsekVal = _activeFilters?['polsek'];
      String? jenisLahanVal = _activeFilters?['jenis_lahan'];
      String? statusVal = _activeFilters?['status_validasi'];

      final List<LandPotentialModel> data = await _service.fetchLandData(
        search: keyword.isNotEmpty ? keyword : _currentSearch,
        polres: polresVal,
        polsek: polsekVal,
        jenisLahan: jenisLahanVal,
        status: statusVal ?? '',
        page: _currentPage,
        limit: _limitPerPage,
      );

      Map<String, List<LandPotentialModel>> grouped = {};

      if (data.isEmpty) {
        if (mounted) {
          setState(() {
            _groupedData = {};
            _isLoading = false;
          });
        }
      } else {
        for (var item in data) {
          String kabName = item.kabupaten.toUpperCase();
          if (!grouped.containsKey(kabName)) grouped[kabName] = [];
          grouped[kabName]!.add(item);
        }

        if (mounted) {
          setState(() {
            _groupedData = grouped;
            _isLoading = false;
          });
          _refreshSummaries();
        }
      }
    } catch (e) {
      debugPrint("Error OverviewPage Fetch: $e");
      if (mounted) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
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
            onAddTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AddLandDataPage()),
              );
              if (result == true) _fetchData();
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchData(),
              color: const Color(0xFF0097B2),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  LandSummaryWidget(key: _summaryKey),
                  NoLandPotentialWidget(key: _noLandKey),
                  _buildHeaderPembatas("DAFTAR POTENSI LAHAN"),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(80),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0097B2),
                        ),
                      ),
                    )
                  else if (_isError)
                    _buildErrorState()
                  else if (_groupedData.isEmpty)
                    _buildEmptyState()
                  else
                    ..._groupedData.entries.map(
                      (entry) => KabupatenExpansionTile(
                        kabupatenName: entry.key,
                        itemsInKabupaten: entry.value,
                        onEdit: (item) async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => AddLandDataPage(editData: item),
                            ),
                          );
                          if (result == true) _fetchData();
                        },
                        onDelete: (item) => _confirmDelete(item),
                        onRefresh: () => _fetchData(),
                      ),
                    ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearch(String val) {
    _currentPage = 1;
    _currentSearch = val;
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
              _currentSearch = "";
              _currentPage = 1;
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
            title: const Text(
              "Hapus Data",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Apakah kamu yakin ingin menghapus data lahan di ${item.alamatLahan}?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text(
                  "BATAL",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(c);
                  setState(() => _isLoading = true);
                  bool success = await _service.deleteLandData(item.id);

                  if (success) {
                    _fetchData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Data berhasil dihapus"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text(
                  "HAPUS",
                  style: TextStyle(color: Colors.white),
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
            "Data tidak ditemukan",
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
              _fetchData();
            },
            child: const Text("Reset Filter"),
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
              "Gagal memuat data",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => _fetchData(),
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderPembatas(String title) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.only(left: 12),
    decoration: const BoxDecoration(
      border: Border(left: BorderSide(color: Color(0xFF0097B2), width: 4)),
    ),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );
}
