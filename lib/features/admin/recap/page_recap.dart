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
    // Memuat data awal saat halaman pertama kali dibuka
    _controller.fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Menangani proses unduh file Excel dengan indikator loading
  void _handleDownloadExcel() async {
    // Menampilkan dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF673AB7)),
          ),
    );

    try {
      final path = await _controller.downloadExcel();

      if (!mounted) return;
      Navigator.pop(context); // Menutup dialog loading

      if (path != null) {
        final String fileName = path.split('/').last;
        PrintSuccessDialog.show(
          context,
          fileName: fileName,
          onPrintTap: () => Navigator.pop(context),
        );
      } else {
        _showErrorSnackBar("Gagal mengunduh file.");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorSnackBar("Terjadi kesalahan saat mengunduh.");
    }
  }

  /// Menangani popup dialog filter kompleks
  void _showFilterDialog() async {
    // Sinkronisasi tipe data: result sekarang Map<String, String> sesuai permintaan filter kompleks
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => RecapFilterDialog(),
    );

    if (result != null && mounted) {
      // Menggunakan fungsi onFilterComplex di controller untuk memicu fetch data backend
      _controller.onFilterComplex(result);
    }
  }

  /// Helper untuk menampilkan pesan error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 1. Header Section: Input pencarian dan tombol aksi (Filter, Download)
          RecapHeaderSection(
            onSearchChanged: _controller.onSearch,
            onFilterTap: _showFilterDialog,
            onPrintTap: _handleDownloadExcel,
          ),

          const SizedBox(height: 16),

          // 2. Table Header: Label kolom statis
          const RecapTableHeader(),

          // 3. Content List: Area data yang bersifat dinamis (reactive)
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                switch (_controller.state) {
                  case RecapState.loading:
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF673AB7),
                      ),
                    );

                  case RecapState.error:
                    return _buildErrorState();

                  case RecapState.empty:
                    return _buildEmptyState();

                  case RecapState.loaded:
                  default:
                    return RecapPaginationWrapper(
                      groupedData: _controller.groupedData,
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// UI saat terjadi kesalahan koneksi/error
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_controller.errorMessage ?? "Terjadi kesalahan"),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _controller.fetchData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
              foregroundColor: Colors.white,
            ),
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  /// UI saat data hasil filter/pencarian tidak ditemukan
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            "Data Tidak Ditemukan",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
