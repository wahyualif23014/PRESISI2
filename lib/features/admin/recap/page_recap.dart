import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/recap/data/model/recap_model.dart';
import 'package:sdmapp/features/admin/recap/data/repo/recap_repo.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_data_row.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_filter_dialog.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_group_section.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_header_section.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_table_header.dart';

// --- IMPORT MODEL & REPO ---

class PageRecap extends StatefulWidget {
  const PageRecap({Key? key}) : super(key: key);

  @override
  State<PageRecap> createState() => _PageRecapState();
}

class _PageRecapState extends State<PageRecap> {
  final RecapRepo _repo = RecapRepo();
  late Future<List<RecapModel>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _repo.getRecapData();
  }

  // --- LOGIC: FILTER DIALOG ---
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const RecapFilterDialog();
      },
    ).then((result) {
      if (result != null) {
        print("Filter diterapkan: $result");
      }
    });
  }

  // --- LOGIC: PRINT ---
  void _handlePrint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Fitur Print belum tersedia"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 1. HEADER SECTION (Search, Filter, Print)
          RecapHeaderSection(
            onSearchChanged: (val) {
              print("Search: $val");
            },
            onFilterTap: _showFilterDialog,
            onPrintTap: _handlePrint,
          ),

          const SizedBox(height: 16),

          // 2. TABLE HEADER (Judul Kolom)
          const RecapTableHeader(),

          // 3. LIST DATA (TREE VIEW)
          Expanded(
            child: FutureBuilder<List<RecapModel>>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1B9E5E)),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Data Tidak Ditemukan"));
                }

                // DATA DARI REPO (FLAT LIST)
                final flatData = snapshot.data!;

                final treeWidgets = _buildTreeStructure(flatData);

                return ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: treeWidgets,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTreeStructure(List<RecapModel> flatData) {
    List<Widget> resultWidgets = [];

    // Variabel penampung sementara
    RecapModel? currentPolres;
    List<Widget> polresChildren = []; // Isinya Polsek Group

    RecapModel? currentPolsek;
    List<Widget> polsekChildren = []; // Isinya Desa Row

    // Fungsi kecil untuk "membungkus" Polsek & Desa yang sudah terkumpul
    void flushPolsek() {
      if (currentPolsek != null) {
        polresChildren.add(
          RecapGroupSection(
            header: currentPolsek!,
            children: List.from(
              polsekChildren,
            ), // Masukkan semua desa yang terkumpul
          ),
        );
        // Reset penampung
        polsekChildren = [];
        currentPolsek = null;
      }
    }

    void flushPolres() {
      flushPolsek(); // Pastikan polsek terakhir diproses dulu
      if (currentPolres != null) {
        resultWidgets.add(
          RecapGroupSection(
            header: currentPolres!,
            children: List.from(
              polresChildren,
            ), // Masukkan semua polsek yang terkumpul
          ),
        );
        // Reset penampung
        polresChildren = [];
        currentPolres = null;
      }
    }

    // --- LOOPING DATA ---
    for (var item in flatData) {
      if (item.type == RecapRowType.polres) {
        flushPolres();
        currentPolres = item; // Set Polres baru
      } else if (item.type == RecapRowType.polsek) {
        flushPolsek();
        currentPolsek = item; // Set Polsek baru
      } else if (item.type == RecapRowType.desa) {
        polsekChildren.add(RecapDataRow(data: item));
      }
    }


    flushPolres();

    return resultWidgets;
  }
}
