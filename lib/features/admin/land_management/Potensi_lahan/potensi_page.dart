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
      // Ambil nilai dari filter dan pastikan tidak null
      String? polresVal = _activeFilters?['polres'];
      String? polsekVal = _activeFilters?['polsek'];

      final List<LandPotentialModel> data = await _service.fetchLandData(
        search: keyword.isNotEmpty ? keyword : _currentSearch,
        polres: polresVal, // Data ini dikirim ke API
        polsek: polsekVal,
        page: _currentPage,
        limit: _limitPerPage,
      );

      Map<String, List<LandPotentialModel>> grouped = {};

      if (data.isEmpty) {
        setState(() {
          _groupedData = {};
          _isLoading = false;
        });
      } else {
        for (var item in data) {
          // Gunakan format string yang lebih rapi untuk header grup
          String fullRegion =
              "POLRES ${item.kabupaten} - POLSEK ${item.kecamatan}";
          if (!grouped.containsKey(fullRegion)) grouped[fullRegion] = [];
          grouped[fullRegion]!.add(item);
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
            onAddTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const AddLandDataPage()),
                ).then((_) => _fetchData()),
          ),
          Expanded(
            child: ListView(
              children: [
                LandSummaryWidget(key: _summaryKey),
                NoLandPotentialWidget(key: _noLandKey),

                _buildHeaderPembatas("DAFTAR POTENSI LAHAN"),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(50),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0097B2),
                      ),
                    ),
                  )
                else if (_groupedData.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Text("🔍", style: TextStyle(fontSize: 50)),
                        const SizedBox(height: 16),
                        const Text(
                          "Data tidak ditemukan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
                  )
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
