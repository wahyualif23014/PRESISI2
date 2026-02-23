import 'dart:async';
import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/repos/kelola_repo.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/presentation/widgets/filter_lahan_dialog.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/presentation/widgets/kelola_list.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/presentation/widgets/kelola_summary.dart';
// Menggunakan toolbar kotak yang sama dengan modul Potensi Lahan
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/land_potential_toolbar.dart';

class KelolaLahanPage extends StatefulWidget {
  const KelolaLahanPage({super.key});

  @override
  State<KelolaLahanPage> createState() => _KelolaLahanPageState();
}

class _KelolaLahanPageState extends State<KelolaLahanPage> {
  final LandManagementRepository _repo = LandManagementRepository();

  // GlobalKey untuk akses fungsi refresh di widget summary
  final GlobalKey<KelolaSummaryWidgetState> _summaryKey = GlobalKey();

  Timer? _debounce;
  List<LandManagementItemModel> _listData = [];
  Map<String, List<LandManagementItemModel>> _groupedData = {};
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
    super.dispose();
  }

  // FUNGSI FETCH: Tetap mempertahankan logika asli Anda
  Future<void> _fetchData({
    String keyword = "",
    Map<String, String>? filters,
  }) async {
    if (filters != null) _activeFilters = filters;
    setState(() => _isLoading = true);

    try {
      final list = await _repo.getLandManagementList(
        keyword: keyword,
        filters: _activeFilters,
      );

      if (!mounted) return;

      setState(() {
        _listData = list;
        _processGrouping(list);
        _isLoading = false;
      });

      // Update angka summary di widget anak secara otomatis
      _summaryKey.currentState?.calculateSummaryFromList(list);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      builder:
          (context) => FilterLahanDialog(
            onApply: (f) => _fetchData(filters: f),
            onReset: () {
              _activeFilters = null;
              _fetchData();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // UI TOOLBAR: Kotak, Border Hitam, Bayangan Tebal (Sesuai Gambar)
          LandPotentialToolbar(
            onSearchChanged: (query) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                _fetchData(keyword: query);
              });
            },
            onFilterTap: _showFilterDialog,
            onAddTap: () {}, // Pertahankan navigasi tambah data jika ada
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                bottom: 100,
              ), // Ruang untuk Bottom Nav
              children: [
                // UI SUMMARY: Expandable dengan icon "i" kuning (Sesuai Gambar)
                KelolaSummaryWidget(key: _summaryKey),

                _buildSectionLabel("DAFTAR PENGELOLAAN LAHAN"),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_listData.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: Text("Data tidak ditemukan"),
                    ),
                  )
                else ...[
                  // UI LIST: Grouping ExpansionTile Ungu (Sesuai Gambar)
                  ..._groupedData.entries.map((entry) {
                    return KelolaRegionExpansionGroup(
                      title: entry.key,
                      items: entry.value,
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Label pembatas vertikal hitam (Sesuai Gambar)
  Widget _buildSectionLabel(String title) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.only(left: 12),
    decoration: const BoxDecoration(
      border: Border(left: BorderSide(color: Colors.black, width: 4)),
    ),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    ),
  );
}
