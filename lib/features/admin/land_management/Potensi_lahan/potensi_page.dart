import 'package:flutter/material.dart';

// 1. IMPORT MODEL & SERVICE
import 'data/model/land_potential_model.dart';
import 'data/service/land_potential_service.dart';

// 2. IMPORT WIDGET LAINNYA
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

  // --- STATE VARIABLES ---
  bool _isLoading = true;
  bool _isError = false;
  Map<String, List<LandPotentialModel>> _groupedData = {};

  // --- FILTER & PAGINATION ---
  String _currentSearch = "";
  String _currentStatus = "";
  String? _filterPolres;
  String? _filterPolsek;
  String? _filterJenisLahan;

  int _currentPage = 1;
  final int _limitPerPage = 50; // LIMIT 10 DATA
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // --- AMBIL DATA DARI SERVER ---
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final List<LandPotentialModel> data = await _service.fetchLandData(
        search: _currentSearch,
        status: _currentStatus,
        polres: _filterPolres,
        polsek: _filterPolsek,
        jenisLahan: _filterJenisLahan,
        page: _currentPage,
        limit: _limitPerPage,
      );

      _hasMoreData = data.length == _limitPerPage;

      // Grouping Data
      Map<String, List<LandPotentialModel>> grouped = {};
      for (var item in data) {
        String namaKabupaten = item.kabupaten.toUpperCase();

        // Fix Nama Kabupaten
        if (!namaKabupaten.startsWith("KABUPATEN") &&
            !namaKabupaten.startsWith("KOTA")) {
          namaKabupaten = "KABUPATEN $namaKabupaten";
        }

        if (!grouped.containsKey(namaKabupaten)) {
          grouped[namaKabupaten] = [];
        }
        grouped[namaKabupaten]!.add(item);
      }

      if (mounted) {
        setState(() {
          _groupedData = grouped;
          _isLoading = false;
        });
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

  // --- LOGIKA EDIT ---
  void _onEdit(LandPotentialModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => AddLandDataPage(editData: item)),
    ).then((_) => _fetchData()); // Refresh setelah edit
  }

  // --- LOGIKA HAPUS ---
  void _onDelete(LandPotentialModel item) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Hapus Data"),
            content: Text(
              "Yakin ingin menghapus data lahan di ${item.alamatLahan}?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(ctx); // Tutup dialog

                  // Loading SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Menghapus data...")),
                  );

                  // Panggil Service Hapus
                  bool success = await _service.deleteLandData(item.id);

                  if (success) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Data berhasil dihapus"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    _fetchData(); // Refresh data
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Gagal menghapus data"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  "Hapus",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  // --- FILTER & SEARCH ---
  void _onSearch(String val) {
    _currentSearch = val;
    _currentPage = 1;
    _fetchData();
  }

  void _onFilterTap() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const LandFilterDialog(),
    );

    if (result != null && result is Map) {
      _currentStatus = result['status'] ?? "";
      _filterPolres = result['polres'];
      _filterPolsek = result['polsek'];
      _filterJenisLahan = result['jenis_lahan'];

      _currentPage = 1;
      _fetchData();
    }
  }

  // --- PAGINATION ---
  void _changePage(int newPage) {
    if (newPage < 1) return;
    setState(() {
      _currentPage = newPage;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // 1. TOOLBAR
          LandPotentialToolbar(
            onSearchChanged: _onSearch,
            onFilterTap: _onFilterTap,
            onAddTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AddLandDataPage()),
              ).then((_) => _fetchData());
            },
          ),

          // 2. LIST DATA
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: LandSummaryWidget(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: NoLandPotentialWidget(),
                ),
                _buildHeaderPembatas("DAFTAR POTENSI LAHAN"),

                // LOGIC TAMPILAN
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_isError)
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text(
                        "Gagal terhubung ke server",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else if (_groupedData.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text(
                        "Belum ada data potensi lahan",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  // TAMPILKAN DATA PER KABUPATEN
                  ..._groupedData.entries.map((entry) {
                    return KabupatenExpansionTile(
                      kabupatenName: entry.key,
                      itemsInKabupaten: entry.value,
                      onEdit: _onEdit, // Pass Fungsi Edit
                      onDelete: _onDelete, // Pass Fungsi Hapus
                    );
                  }),

                // TOMBOL PAGINATION
                if (!_isLoading && !_isError && _groupedData.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed:
                              _currentPage > 1
                                  ? () => _changePage(_currentPage - 1)
                                  : null,
                          icon: const Icon(Icons.arrow_back_ios, size: 16),
                          color: _currentPage > 1 ? Colors.black : Colors.grey,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            "Halaman $_currentPage",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _hasMoreData
                                  ? () => _changePage(_currentPage + 1)
                                  : null,
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          color: _hasMoreData ? Colors.black : Colors.grey,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPembatas(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      padding: const EdgeInsets.only(left: 12.0),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Colors.black, width: 4.0)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
