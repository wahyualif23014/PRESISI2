import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'data/model/land_potential_model.dart';
import 'data/service/land_potential_service.dart';
import 'presentation/widget/add_land_data_page.dart';
import 'presentation/widget/land_filter_dialog.dart';
import 'presentation/widget/land_potential_group.dart';
import 'presentation/widget/land_potential_toolbar.dart';
import 'presentation/widget/land_summary_widget.dart';
import 'presentation/widget/no_land_potential_widget.dart';
import 'package:KETAHANANPANGAN/shared/widget/skeleton_loading.dart';

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

  /// Menerapkan filter otomatis berdasarkan role user yang login.
  /// - Operator Polsek: hanya melihat data Polsek-nya sendiri.
  /// - Admin Polres: hanya melihat data Polres-nya (semua Polsek di bawahnya).
  /// - Admin Polda / Viewer: melihat semua data.
  void _applyRoleBasedFilters(Map<String, String> filters) {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final roleString = auth.user?.role?.toString() ?? '';
    final unitName = auth.user?.tingkatDetail?.nama ?? '';
    final unitNameUpper = unitName.toUpperCase();

    if (roleString.contains('admin')) return;
    if (unitNameUpper.isEmpty) return;

    if (unitNameUpper.contains('POLRES')) {
      // Admin/Operator Polres → scope ke polres-nya
      filters['polres'] = unitName;
    } else if (unitNameUpper.contains('POLSEK')) {
      // Operator Polsek → scope ke polsek-nya
      filters['polsek'] = unitName;
    }
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

    // Buat salinan filter agar tidak mengubah _activeFilters langsung
    final effectiveFilters = Map<String, String>.from(_activeFilters ?? {});
    _applyRoleBasedFilters(effectiveFilters);

    try {
      String? polresVal = effectiveFilters['polres'];
      String? polsekVal = effectiveFilters['polsek'];
      String? jenisLahanVal = effectiveFilters['jenis_lahan'];
      String? statusVal = effectiveFilters['status_validasi'];

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
              final result = await Navigator.of(context, rootNavigator: true).push(
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
                    SkeletonLoading.listCard(count: 3)
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
                          final result = await Navigator.of(context, rootNavigator: true).push(
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
