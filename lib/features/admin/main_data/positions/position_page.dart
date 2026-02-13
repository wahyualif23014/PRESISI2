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
    // Fetch data saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JabatanProvider>().fetchJabatan();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFormModal(BuildContext context, JabatanFormType type, {JabatanModel? item}) {
    final jabatanCtrl = TextEditingController(text: item?.namaJabatan ?? '');
    
    // Field ini opsional di backend, tapi jika ada, kita tampilkan
    final namaCtrl = TextEditingController(text: item?.namaPejabat ?? '');
    final nrpCtrl = TextEditingController(text: item?.nrp ?? '');
    final tglCtrl = TextEditingController(text: item?.tanggalPeresmian ?? '');


    String? selectedIdAnggota = item?.idAnggota; 

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: JabatanFormWidget(
            type: type,
            jabatanController: jabatanCtrl,
            namaController: namaCtrl,
            nrpController: nrpCtrl,
            tanggalController: tglCtrl,
            onCancel: () => Navigator.pop(ctx),
            
            // LOGIKA SUBMIT
            onSubmit: () {
              final provider = context.read<JabatanProvider>();

              if (type == JabatanFormType.add) {
                // Panggil Provider Add
                provider.addNewData(
                  jabatanCtrl.text, 
                  selectedIdAnggota 
                );
                _showSnackBar("Proses tambah data...");
              } else if (type == JabatanFormType.edit) {
                if (item != null) {
                  provider.updateData(
                    item.id, 
                    jabatanCtrl.text, 
                    selectedIdAnggota
                  );
                  _showSnackBar("Proses update data...");
                }
              } else {
                // DELETE
                if (item != null) {
                  provider.deleteSingle(item.id);
                  _showSnackBar("Data dihapus");
                } else {
                  provider.deleteSelected();
                  _showSnackBar("Data terpilih dihapus");
                }
              }
              Navigator.pop(ctx);
            },
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      body: Consumer<JabatanProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // --- 1. HEADER (SEARCH & ACTION) ---
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Column(
                  children: [
                    Row(
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
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- 2. SELECTION BAR ---
              if (provider.displayData.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 0.9,
                        child: Checkbox(
                          value: provider.isAllSelected,
                          onChanged: (val) => provider.toggleSelectAll(val),
                          activeColor: const Color(0xFF6366F1),
                        ),
                      ),
                      Text(
                        provider.selectedCount > 0
                            ? "${provider.selectedCount} Dipilih"
                            : "Pilih Semua",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

              // --- 3. DATA GRID ---
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.errorMessage != null
                        ? Center(child: Text(provider.errorMessage!))
                        : provider.displayData.isEmpty
                            ? _buildEmptyState()
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: GridView.builder(
                                  padding: const EdgeInsets.only(top: 16, bottom: 80),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.70,
                                  ),
                                  itemCount: provider.displayData.length,
                                  itemBuilder: (context, index) {
                                    final item = provider.displayData[index];
                                    return JabatanCardItem(
                                      item: item,
                                      onToggleSelection: () => provider.toggleSingleSelection(item.id),
                                      onEdit: () => _showFormModal(context, JabatanFormType.edit, item: item),
                                      onDelete: () => _showFormModal(context, JabatanFormType.delete, item: item),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "Data jabatan tidak ditemukan",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}