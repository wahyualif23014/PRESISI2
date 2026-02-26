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

  void _handleDownloadExcel() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF673AB7)),
      ),
    );

    try {
      final path = await _controller.downloadExcel();

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (path != null) {
        final String fileName = path.split('/').last;
        PrintSuccessDialog.show(
          context,
          fileName: fileName,
          onPrintTap: () => Navigator.pop(context),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengunduh."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _showFilterDialog() async {
    final result = await showDialog<Map<String, bool>>(
      context: context,
      builder: (context) => const RecapFilterDialog(),
    );

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
          RecapHeaderSection(
            onSearchChanged: _controller.onSearch,
            onFilterTap: _showFilterDialog,
            onPrintTap: _handleDownloadExcel,
          ),
          const SizedBox(height: 16),
          const RecapTableHeader(),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                if (_controller.state == RecapState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF673AB7)),
                  );
                }

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

                if (_controller.state == RecapState.empty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Data Kosong",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

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