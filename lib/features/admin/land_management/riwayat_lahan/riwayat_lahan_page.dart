import 'dart:async';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/models/lahan_history_model.dart' show LandHistoryItemModel;
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/providers/land_history_provider.dart' show LandHistoryProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  Timer? _debounce;

  Map<String, List> _groupedData = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LandHistoryProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String keyword) {
    context.read<LandHistoryProvider>().setSearch(keyword);
  }

  void _showFilterDialog() {

    showDialog(
      context: context,
      builder: (context) {

        return FilterriwayatDialog(
          onApply: (filters) {
            filters.forEach((key, value) {
              context.read<LandHistoryProvider>().setFilter(key, value);
            });
          },
          onReset: () {
            _searchController.clear();
            context.read<LandHistoryProvider>().clearFilters();
          },
        );
      },
    );
  }

  Map<String, List> _groupHistory(List items) {

    Map<String, List> grouped = {};

    for (var item in items) {
      grouped.putIfAbsent(item.regionGroup, () => []).add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<LandHistoryProvider>();

    final historyList = provider.historyList;

    _groupedData = _groupHistory(historyList);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          /// ================= SEARCH BAR =================

          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SearchLahanHistory(
              controller: _searchController,
              onChanged: (val) {

                if (_debounce?.isActive ?? false) {
                  _debounce!.cancel();
                }

                _debounce = Timer(const Duration(milliseconds: 500), () {
                  _onSearch(val);
                });
              },
              onFilterTap: _showFilterDialog,
            ),
          ),

          /// ================= CONTENT =================

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<LandHistoryProvider>().initialize();
              },
              color: const Color(0xFF1A237E),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80, top: 8),
                children: [

                  /// ================= SUMMARY =================

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const HistorySummary(),
                  ),

                  /// ================= HEADER =================

                  _buildHeaderPembatas("DAFTAR RIWAYAT LAHAN"),

                  /// ================= LOADING =================

                  if (provider.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(80),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    )

                  /// ================= EMPTY =================

                  else if (_groupedData.isEmpty)
                    _buildEmptyState()

                  /// ================= LIST =================

                  else
                    ..._groupedData.entries.map((entry) {

                      return HistoryRegionExpansionTile(
                        title: entry.key,
                        items: entry.value.cast<LandHistoryItemModel>(),
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

              context.read<LandHistoryProvider>().clearFilters();
              _searchController.clear();

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