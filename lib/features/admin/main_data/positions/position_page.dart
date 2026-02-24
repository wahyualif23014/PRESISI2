import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Provider
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/providers/jabatan_provider.dart';

// Import Models & Widgets
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/models/position_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/presentation/widgets/jabatan_action_buttons.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/presentation/widgets/jabatan_form_widget.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/presentation/widgets/jabatan_card_item.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/presentation/widgets/jabatan_search_bar.dart';

class PositionPage extends StatefulWidget {
  const PositionPage({super.key});

  @override
  State<PositionPage> createState() => _PositionPageState();
}

class _PositionPageState extends State<PositionPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<JabatanProvider>().fetchJabatan();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFormModal(
    BuildContext context,
    JabatanFormType type, {
    JabatanModel? item,
  }) {
    final jabatanCtrl = TextEditingController(text: item?.namaJabatan ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: JabatanFormWidget(
            type: type,
            jabatanController: jabatanCtrl,
            namaController: TextEditingController(),
            nrpController: TextEditingController(),
            tanggalController: TextEditingController(),
            onCancel: () => Navigator.pop(ctx),
            onSubmit: () async {
              final provider = context.read<JabatanProvider>();

              if (type == JabatanFormType.add) {
                await provider.addNewData(jabatanCtrl.text);
                _showSnackBar("Jabatan berhasil ditambahkan");
              } else if (type == JabatanFormType.edit && item != null) {
                await provider.updateData(item.id, jabatanCtrl.text);
                _showSnackBar("Jabatan berhasil diperbarui");
              } else if (type == JabatanFormType.delete) {
                if (item != null) {
                  item.isSelected = true;
                  await provider.deleteSelected();
                  _showSnackBar("Data '${item.namaJabatan}' berhasil dihapus");
                } else {
                  await provider.deleteSelected();
                  _showSnackBar("Data terpilih berhasil dihapus");
                }
              }

              if (mounted) Navigator.pop(ctx);
            },
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF2D4F1E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F9),
      body: Consumer<JabatanProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildHeader(provider),
              if (provider.displayData.isNotEmpty) _buildSelectionBar(provider),
              Expanded(
                child:
                    provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : provider.displayData.isEmpty
                        ? _buildEmptyState(
                          provider,
                        ) // Pass provider untuk refresh saat kosong
                        : _buildDataGrid(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(JabatanProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: JabatanSearchBar(
              controller: _searchController,
              onChanged: (value) => provider.search(value),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: JabatanActionButtons(
              onAdd: () => _showFormModal(context, JabatanFormType.add),
              onDelete: () {
                if (provider.selectedCount > 0) {
                  _showFormModal(context, JabatanFormType.delete);
                } else {
                  _showSnackBar("Pilih data yang ingin dihapus");
                }
              },
              onRefresh: () {
                provider.fetchJabatan();
                _searchController.clear();
                _showSnackBar("Data diperbarui");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar(JabatanProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: provider.isAllSelected,
              onChanged: (val) => provider.toggleSelectAll(val),
              activeColor: const Color(0xFF2D4F1E),
            ),
          ),
          Text(
            provider.selectedCount > 0
                ? "${provider.selectedCount} Item Dipilih"
                : "Pilih Semua",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // --- IMPLEMENTASI PULL TO REFRESH ---
  Widget _buildDataGrid(JabatanProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.fetchJabatan(),
      color: const Color(0xFF2D4F1E),
      backgroundColor: Colors.white,
      child: GridView.builder(
        // AlwaysScrollableScrollPhysics agar pull-to-refresh tetap aktif meski data sedikit
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: 80,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemCount: provider.displayData.length,
        itemBuilder: (context, index) {
          final item = provider.displayData[index];
          return JabatanCardItem(
            item: item,
            onToggleSelection: () => provider.toggleSingleSelection(item.id),
            onEdit:
                () => _showFormModal(context, JabatanFormType.edit, item: item),
            onDelete:
                () =>
                    _showFormModal(context, JabatanFormType.delete, item: item),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(JabatanProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.fetchJabatan(),
      color: const Color(0xFF2D4F1E),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                "Belum ada data jabatan",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tarik ke bawah untuk memuat ulang",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
