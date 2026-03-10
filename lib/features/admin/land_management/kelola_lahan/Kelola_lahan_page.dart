import 'dart:async';
import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/repos/kelola_repo.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/presentation/widgets/kelola_list.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/presentation/widgets/kelola_summary.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/presentation/widgets/search_kelola_lahan.dart';

class KelolaLahanPage extends StatefulWidget {
  const KelolaLahanPage({super.key});

  @override
  State<KelolaLahanPage> createState() => _KelolaLahanPageState();
}

class _KelolaLahanPageState extends State<KelolaLahanPage> {
  final LandManagementRepository _repo = LandManagementRepository();
  final GlobalKey<KelolaSummaryWidgetState> _summaryKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<LandManagementItemModel> _listData = [];
  Map<String, List<LandManagementItemModel>> _groupedData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Ambil data saat pertama kali buka
  }

  // FUNGSI UTAMA UNTUK REFRESH DATA
  Future<void> _fetchData({String keyword = ""}) async {
    setState(() => _isLoading = true);

    // Ambil data terbaru dari repository
    final list = await _repo.getLandManagementList(
      keyword: keyword.isNotEmpty ? keyword : _searchController.text,
    );

    if (mounted) {
      setState(() {
        _listData = list;
        _groupedData = {};
        for (var item in list) {
          _groupedData.putIfAbsent(item.regionGroup, () => []).add(item);
        }
        _isLoading = false;
      });
      _summaryKey.currentState?.calculateSummaryFromList(list);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchKelolaLahan(
              controller: _searchController,
              onChanged: (query) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 500),
                  () => _fetchData(keyword: query),
                );
              },
              onFilterTap: () {},
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchData(), // FITUR TARIK KEBAWAH
              color: const Color(0xFF0097B2),
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Wajib ada agar RefreshIndicator jalan
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  KelolaSummaryWidget(key: _summaryKey),
                  if (_isLoading && _listData.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    ..._groupedData.entries.map(
                      (e) => KelolaRegionExpansionGroup(
                        title: e.key,
                        items: e.value,
                        onRefresh:
                            () =>
                                _fetchData(), // Memicu refresh setelah edit sukses
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
