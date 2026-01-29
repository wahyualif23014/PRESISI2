import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/controllers/recap_controller.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/PrintSuccess.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/recap_data_row.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/recap_filter_dialog.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/recap_header_section.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/recap_table_header.dart';

class PageRecap extends StatefulWidget {
  const PageRecap({Key? key}) : super(key: key);

  @override
  State<PageRecap> createState() => _PageRecapState();
}

class _PageRecapState extends State<PageRecap> {
  final RecapController _controller = RecapController();

  @override
  void initState() {
    super.initState();
    _controller.fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => const RecapFilterDialog(),
    ).then((result) {
      if (result != null) {
        // Implementasi logika filter controller di sini
        // _controller.applyFilter(result);
      }
    });
  }

  void _handlePrint() {
    PrintSuccessDialog.show(
      context,
      fileName: "Data_Recap.pdf",
      onPrintTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Membuka File PDF...")),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 1. Header Section (Search, Filter, Print)
          RecapHeaderSection(
            onSearchChanged: (val) {
              // _controller.onSearch(val);
            },
            onFilterTap: _showFilterDialog,
            onPrintTap: _handlePrint,
          ),

          const SizedBox(height: 16),

          // 2. Table Header (Judul Kolom)
          // const RecapTableHeader(),

          // 3. Data Content
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                switch (_controller.state) {
                  case RecapState.loading:
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF1B9E5E)),
                    );

                  case RecapState.error:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            "Terjadi Kesalahan:\n${_controller.errorMessage}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _controller.fetchData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B9E5E),
                            ),
                            child: const Text("Coba Lagi"),
                          )
                        ],
                      ),
                    );

                  case RecapState.empty:
                    return const Center(
                      child: Text("Data Tidak Ditemukan", style: TextStyle(color: Colors.grey)),
                    );

                  case RecapState.loaded:
                  default:
                    // Render List berdasarkan Grouped Map dari Controller
                    final dataMap = _controller.groupedData;
                    
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: dataMap.length,
                      itemBuilder: (context, index) {
                        final entry = dataMap.entries.elementAt(index);
                        
                        // Pass data ke Widget Level 1 (Polres)
                        return RecapPolresSection(
                          polresName: entry.key,
                          itemsInPolres: entry.value,
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}