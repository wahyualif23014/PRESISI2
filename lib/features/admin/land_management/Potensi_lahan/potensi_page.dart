import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/controllers/land_potential_controller.dart';
// Import Controller yang baru dibuat

// Import widget yang sudah ada
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/add_land_data_page.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/land_filter_dialog.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/land_potential_group.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/land_potential_toolbar.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/land_summary_widget.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/no_land_potential_widget.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  // 1. Panggil Controller
  final LandPotentialController _controller = LandPotentialController();

  @override
  void initState() {
    super.initState();
    // 2. Fetch data saat inisialisasi
    _controller.fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Actions dipisah agar rapi ---
  void _showFilter() {
    showDialog(
      context: context,
      builder: (_) => const LandFilterDialog(),
    );
  }

  void _navigateToAddPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddLandDataPage()),
    ).then((_) {
      // Opsional: Refresh data setelah kembali dari halaman tambah
      // _controller.fetchData(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // A. TOOLBAR
          LandPotentialToolbar(
            onSearchChanged: (query) => print("Mencari: $query"),
            onFilterTap: _showFilter,
            onAddTap: _navigateToAddPage,
          ),

          // B. CONTEN (Reactive)
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                switch (_controller.state) {
                  case LandState.loading:
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF1B9E5E)),
                    );

                  case LandState.error:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text("Terjadi kesalahan: ${_controller.errorMessage}"),
                          TextButton(
                            onPressed: _controller.fetchData,
                            child: const Text("Coba Lagi"),
                          ),
                        ],
                      ),
                    );
                  
                  // Empty & Loaded digabung list-nya agar struktur tetap terjaga 
                  // (Header Summary & NoLandWidget tetap muncul walau kosong)
                  case LandState.empty:
                  case LandState.loaded:
                  default:
                    return ListView(
                      padding: const EdgeInsets.only(bottom: 100),
                      children: [
                        // 1. Widget Summary & Info (Selalu muncul)
                        const LandSummaryWidget(),
                        const NoLandPotentialWidget(),
                        
                        // 2. Header Pembatas
                        _buildHeaderPembatas("Daftar Potensi Lahan"),

                        // 3. Logic Tampilan Data
                        if (_controller.state == LandState.empty)
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
                          // Render Data yang sudah dikelompokkan di Controller
                          ..._controller.groupedData.entries.map((entry) {
                            return KabupatenExpansionTile(
                              kabupatenName: entry.key,
                              itemsInKabupaten: entry.value,
                            );
                          }),
                      ],
                    );
                }
              },
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
        border: Border(
          left: BorderSide(
            color: Colors.black, 
            width: 4.0, 
          ),
        ),
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