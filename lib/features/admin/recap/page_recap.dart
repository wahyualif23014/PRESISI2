import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/recap/data/model/recap_model.dart';
import 'package:sdmapp/features/admin/recap/data/repo/recap_repo.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_data_row.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_filter_dialog.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_group_section.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_header_section.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_table_header.dart';

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

  // --- UPDATED: IMPLEMENTASI PRINT WIDGET ---
  void _handlePrint() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: PrintSuccessWidget(
            fileName: "Data-desa-Kamal.pdf",
            onPrintTap: () {
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Membuka File PDF...")),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 16),
          RecapHeaderSection(
            onSearchChanged: (val) {},
            onFilterTap: _showFilterDialog,
            onPrintTap: _handlePrint,
          ),
          const SizedBox(height: 16),
          const RecapTableHeader(),
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
    RecapModel? currentPolres;
    List<Widget> polresChildren = [];
    RecapModel? currentPolsek;
    List<Widget> polsekChildren = [];

    void flushPolsek() {
      if (currentPolsek != null) {
        polresChildren.add(
          RecapGroupSection(
            header: currentPolsek!,
            children: List.from(polsekChildren),
          ),
        );
        polsekChildren = [];
        currentPolsek = null;
      }
    }

    void flushPolres() {
      flushPolsek();
      if (currentPolres != null) {
        resultWidgets.add(
          RecapGroupSection(
            header: currentPolres!,
            children: List.from(polresChildren),
          ),
        );
        polresChildren = [];
        currentPolres = null;
      }
    }

    for (var item in flatData) {
      if (item.type == RecapRowType.polres) {
        flushPolres();
        currentPolres = item;
      } else if (item.type == RecapRowType.polsek) {
        flushPolsek();
        currentPolsek = item;
      } else if (item.type == RecapRowType.desa) {
        polsekChildren.add(RecapDataRow(data: item));
      }
    }

    flushPolres();
    return resultWidgets;
  }
}

// --- NEW WIDGET: PRINT SUCCESS ---

class PrintSuccessWidget extends StatelessWidget {
  final String fileName;
  final VoidCallback onPrintTap;

  const PrintSuccessWidget({
    Key? key,
    required this.fileName,
    required this.onPrintTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.picture_as_pdf_outlined, size: 70, color: Color(0xFF2F80ED)),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.white, spreadRadius: 2)],
                    ),
                    child: const Icon(Icons.check, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fileName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPrintTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.verified, color: Color(0xFF00C853), size: 20),
                SizedBox(width: 6),
                Text(
                  "File Berhasil Terunduh",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2F80ED),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}