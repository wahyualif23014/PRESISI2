import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/recap/presentation/controllers/recap_controller.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/PrintSuccess.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_filter_dialog.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_header_section.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_table_header.dart';


class PageRecap extends StatefulWidget {
  const PageRecap({Key? key}) : super(key: key);

  @override
  State<PageRecap> createState() => _PageRecapState();
}

class _PageRecapState extends State<PageRecap> {
  // Instance Controller
  final RecapController _controller = RecapController();

  @override
  void initState() {
    super.initState();
    // Fetch data hanya sekali saat inisialisasi
    _controller.fetchData();
  }

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }

  // --- ACTIONS ---
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => const RecapFilterDialog(),
    ).then((result) {
      if (result != null) {

        print("Filter diterapkan: $result");
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

          // 1. Header Section
          RecapHeaderSection(
            onSearchChanged: (val) {
              // _controller.search(val); 
            },
            onFilterTap: _showFilterDialog,
            onPrintTap: _handlePrint,
          ),

          const SizedBox(height: 16),

          // 2. Table Header
          const RecapTableHeader(),

          // 3. Data Content (Reactive UI)
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                // Menangani State dengan Switch Case agar rapi
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
                          TextButton(
                            onPressed: _controller.fetchData,
                            child: const Text("Coba Lagi"),
                          )
                        ],
                      ),
                    );

                  case RecapState.empty:
                    return const Center(
                      child: Text("Data Tidak Ditemukan"),
                    );

                  case RecapState.loaded:
                  default:
                    // Render list yang sudah disiapkan oleh Controller
                    return ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: _controller.treeWidgets,
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