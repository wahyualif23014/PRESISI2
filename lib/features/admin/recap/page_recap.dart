import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/controllers/recap_controller.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/PrintSuccess.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/recap_filter_dialog.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/recap_header_section.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/recap_table_header.dart';
import 'package:KETAHANANPANGAN/features/admin/recap/presentation/widgets/recap_pagination_wrapper.dart';

class PageRecap extends StatefulWidget {
  const PageRecap({super.key});

  @override
  State<PageRecap> createState() => _PageRecapState();
}

class _PageRecapState extends State<PageRecap> {
  final RecapController _controller = RecapController();
  bool _isDownloading = false;

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

  void _handleDownloadExcel(String selection) async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const PopScope(
            canPop: false,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF673AB7)),
            ),
          ),
    );

    try {
      final path = await _controller.downloadExcel(selection: selection);

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      if (path != null) {
        final String fileName = path.split('/').last;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            PrintSuccessDialog.show(context, fileName: fileName);
          }
        });
      } else {
        _showErrorSnackBar("Gagal mengunduh file.");
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showErrorSnackBar("Terjadi kesalahan saat mengunduh.");
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  void _showFilterDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const RecapFilterDialog(),
    );
    if (result != null && mounted) {
      _controller.onFilterComplex(result);
    }
  }

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
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return RecapHeaderSection(
                onSearchChanged: _controller.onSearch,
                onFilterTap: _showFilterDialog,
                onDownloadExcel: _handleDownloadExcel,
              );
            },
          ),
          const SizedBox(height: 16),
          const RecapTableHeader(),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return _buildBodyContent();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_controller.state) {
      case RecapState.loading:
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF673AB7)),
        );
      case RecapState.error:
        return _buildErrorState();
      case RecapState.empty:
        return _buildEmptyState();
      case RecapState.loaded:
      default:
        return RecapPaginationWrapper(
          allItems: _controller.allItems,
          groupedData: _controller.groupedData,
          onToggle: _controller.toggleSelection,
          onRefresh: _controller.fetchData,
        );
    }
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_controller.errorMessage ?? "Terjadi kesalahan"),
            const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        child: const Text(
          "Data Tidak Ditemukan",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
