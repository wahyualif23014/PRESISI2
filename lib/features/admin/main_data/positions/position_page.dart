import 'package:flutter/material.dart';

import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/models/position_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/repos/position_repository.dart';

import 'package:KETAHANANPANGAN/features/admin/main_data/positions/presentation/widgets/jabatan_action_buttons.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/presentation/widgets/jabatan_form_widget.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/presentation/widgets/jabatan_card_item.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/presentation/widgets/jabatan_search_bar.dart';

class JabatanController extends ChangeNotifier {
  List<JabatanModel> _allData = [];
  List<JabatanModel> displayData = [];
  bool isLoading = true;

  JabatanController() {
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading = true;
    notifyListeners();
    
    try {
      _allData = await JabatanRepository.getJabatanList();
      displayData = List.from(_allData);
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void runSearch(String query) {
    if (query.isEmpty) {
      displayData = List.from(_allData);
    } else {
      displayData = _allData.where((item) {
        final titleLower = item.namaJabatan.toLowerCase();
        final nameLower = (item.namaPejabat ?? '').toLowerCase();
        final searchLower = query.toLowerCase();
        return titleLower.contains(searchLower) || nameLower.contains(searchLower);
      }).toList();
    }
    notifyListeners();
  }

  void toggleSelectAll(bool? val) {
    if (val != null) {
      for (var item in displayData) {
        item.isSelected = val;
      }
      notifyListeners();
    }
  }

  void toggleSingleSelection(String id) {
    final index = displayData.indexWhere((e) => e.id == id);
    if (index != -1) {
      displayData[index].isSelected = !displayData[index].isSelected;
      notifyListeners();
    }
  }

  void addNewData(String jabatan, String nama, String nrp, String tgl) {
    final newItem = JabatanModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      namaJabatan: jabatan.isEmpty ? "Jabatan Baru" : jabatan,
      namaPejabat: nama.isEmpty ? "Personel Baru" : nama,
      nrp: nrp,
      tanggalPeresmian: tgl,
    );
    _allData.add(newItem);
    runSearch(""); 
  }

  void editData(JabatanModel item, String jabatan, String nama, String nrp, String tgl) {
    // LOGIKA KOSONG
  }

  void deleteSingle(String id) {
    displayData.removeWhere((e) => e.id == id);
    _allData.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void deleteSelected() {
    displayData.removeWhere((e) => e.isSelected);
    _allData.removeWhere((e) => e.isSelected);
    notifyListeners();
  }

  void refreshData() {
    _loadData();
  }

  int get selectedCount => displayData.where((e) => e.isSelected).length;
  bool get isAllSelected => displayData.isNotEmpty && displayData.length == selectedCount;
}

class PositionPage extends StatefulWidget {
  const PositionPage({super.key});

  @override
  State<PositionPage> createState() => _PositionPageState();
}

class _PositionPageState extends State<PositionPage> {
  final TextEditingController _searchController = TextEditingController();
  late JabatanController _controller;

  @override
  void initState() {
    super.initState();
    _controller = JabatanController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showFormModal(BuildContext context, JabatanFormType type, {JabatanModel? item}) {
    final jabatanCtrl = TextEditingController(text: item?.namaJabatan ?? '');
    final namaCtrl = TextEditingController(text: item?.namaPejabat ?? '');
    final nrpCtrl = TextEditingController(text: item?.nrp ?? '');
    final tglCtrl = TextEditingController(text: item?.tanggalPeresmian ?? '');

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
            onSubmit: () {
              if (type == JabatanFormType.add) {
                _controller.addNewData(
                  jabatanCtrl.text,
                  namaCtrl.text,
                  nrpCtrl.text,
                  tglCtrl.text,
                );
                _showSnackBar("Data Berhasil Ditambah");
              } else if (type == JabatanFormType.edit) {
                
                // LOGIKA EDIT KOSONG

              } else {
                if (item != null) {
                  _controller.deleteSingle(item.id);
                } else {
                  _controller.deleteSelected();
                }
                _showSnackBar("Data Berhasil Dihapus");
              }
              Navigator.pop(ctx);
            },
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF8FAFC); 

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
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
                        onChanged: (value) => _controller.runSearch(value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: JabatanActionButtons(
                        onAdd: () => _showFormModal(context, JabatanFormType.add),
                        onDelete: () {
                          if (_controller.selectedCount > 0) {
                            _controller.deleteSelected();
                            _showSnackBar("${_controller.selectedCount} data dihapus");
                          } else {
                            _showSnackBar("Pilih data yang ingin dihapus");
                          }
                        },
                        onRefresh: () {
                          _controller.refreshData();
                          _searchController.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: _controller.isAllSelected,
                    onChanged: (val) => _controller.toggleSelectAll(val),
                    activeColor: const Color(0xFF6366F1),
                  ),
                ),
                Text(
                  _controller.selectedCount > 0 
                      ? "${_controller.selectedCount} Dipilih" 
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

          Expanded(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _controller.displayData.isEmpty
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
                          itemCount: _controller.displayData.length,
                          itemBuilder: (context, index) {
                            final item = _controller.displayData[index];
                            return JabatanCardItem(
                              item: item,
                              onToggleSelection: () => _controller.toggleSingleSelection(item.id),
                              onEdit: () => _showFormModal(context, JabatanFormType.edit, item: item), 
                              onDelete: () => _showFormModal(context, JabatanFormType.delete, item: item), 
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_rounded, size: 64, color: Colors.grey.shade300),
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