import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/controllers/recap_controller.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/PrintSuccess.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/recap_filter_dialog.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/recap_header_section.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/recap_table_header.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/recap_pagination_wrapper.dart';

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

  // --- LOGIKA DOWNLOAD EXCEL ---
  void _handleDownloadExcel() async {
    // Tampilkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF673AB7)),
      ),
    );

    // Proses Download
    final path = await _controller.downloadExcel();
    
    if (!mounted) return;
    Navigator.pop(context); // Tutup Loading

    if (path != null) {
      // Tampilkan Dialog Sukses
      final String fileName = path.split('/').last;
      PrintSuccessDialog.show(
        context,
        fileName: fileName,
        onPrintTap: () => Navigator.pop(context),
      );
    } else {
      // Tampilkan Error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengunduh."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- LOGIKA FILTER (POPUP DIALOG) ---
  void _showFilterDialog() async {
    // Menggunakan showDialog agar tampil sebagai POPUP di tengah layar
    final result = await showDialog<Map<String, bool>>(
      context: context,
      // HAPUS 'const' di sini untuk memperbaiki error
      builder: (context) => RecapFilterDialog(),
    );

    // Kirim hasil filter ke controller jika user menekan 'Terapkan'
    if (result != null) {
      _controller.onFilter(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 1. HEADER SECTION (Search, Filter, Download)
          RecapHeaderSection(
            onSearchChanged: _controller.onSearch,
            onFilterTap: _showFilterDialog, // Panggil fungsi Dialog Popup
            onPrintTap: _handleDownloadExcel,
          ),

          const SizedBox(height: 16),

          // 2. TABLE HEADER (Judul Kolom)
          const RecapTableHeader(),

          // 3. CONTENT LIST (Data)
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                // State Loading
                if (_controller.state == RecapState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF673AB7)),
                  );
                }
                
                // State Error
                if (_controller.state == RecapState.error) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: _controller.fetchData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Coba Lagi"),
                    ),
                  );
                }
                
                // State Kosong
                if (_controller.state == RecapState.empty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Data Kosong", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // State Sukses -> Tampilkan Pagination Wrapper
                return RecapPaginationWrapper(
                  groupedData: _controller.groupedData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}