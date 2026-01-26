// Lokasi: lib/features/admin/main_data/jabatan/pages/jabatan_page.dart

import 'package:flutter/material.dart';

// --- DATA LAYER ---
import 'package:sdmapp/features/admin/main_data/positions/data/models/position_model.dart';
import 'package:sdmapp/features/admin/main_data/positions/data/repos/position_repository.dart';

// --- WIDGETS UI ---
import 'package:sdmapp/features/admin/main_data/positions/presentation/widgets/jabatan_action_buttons.dart';
import 'package:sdmapp/features/admin/main_data/positions/presentation/widgets/jabatan_form_widget.dart';
import 'package:sdmapp/features/admin/main_data/positions/presentation/widgets/jabatan_list_header.dart';
import 'package:sdmapp/features/admin/main_data/positions/presentation/widgets/jabatan_list_item.dart';
import 'package:sdmapp/features/admin/main_data/positions/presentation/widgets/jabatan_search_bar.dart';

// --- FORM WIDGET ---

class PositionPage extends StatefulWidget {
  const PositionPage({super.key});

  @override
  State<PositionPage> createState() => _PositionPageState();
}

class _PositionPageState extends State<PositionPage> {
  final TextEditingController _searchController = TextEditingController();

  // Local State
  List<JabatanModel> _allData = [];
  List<JabatanModel> _displayData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulasi ambil data dari Repository
    final data = await JabatanRepository.getJabatanList();
    if (mounted) {
      setState(() {
        _allData = data;
        _displayData = List.from(_allData);
        _isLoading = false;
      });
    }
  }

  // --- LOGIC SEARCH & FILTER ---
  void _runSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayData = List.from(_allData);
      } else {
        _displayData = _allData.where((item) {
          final titleLower = item.namaJabatan.toLowerCase();
          final nameLower = (item.namaPejabat ?? '').toLowerCase();
          final searchLower = query.toLowerCase();
          return titleLower.contains(searchLower) || nameLower.contains(searchLower);
        }).toList();
      }
    });
  }

  // --- LOGIC SELECTION ---
  void _toggleSelectAll(bool? val) {
    setState(() {
      if (val != null) {
        for (var item in _displayData) {
          item.isSelected = val;
        }
      }
    });
  }

  void _toggleSingleSelection(String id) {
    setState(() {
      final index = _displayData.indexWhere((e) => e.id == id);
      if (index != -1) {
        _displayData[index].isSelected = !_displayData[index].isSelected;
      }
    });
  }

  int get _selectedCount => _displayData.where((e) => e.isSelected).length;
  bool get _isAllSelected => _displayData.isNotEmpty && _displayData.length == _selectedCount;

  // --- LOGIC CRUD (UI ONLY) ---
  void _addNewData(String jabatan, String nama, String nrp, String tgl) {
    setState(() {
      final newItem = JabatanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        namaJabatan: jabatan.isEmpty ? "Jabatan Baru" : jabatan,
        namaPejabat: nama.isEmpty ? "Personel Baru" : nama,
        nrp: nrp,
        tanggalPeresmian: tgl,
      );
      _allData.add(newItem);
      _displayData = List.from(_allData); // Refresh list
    });
  }

  void _deleteSingle(String id) {
    setState(() {
      _displayData.removeWhere((e) => e.id == id);
      _allData.removeWhere((e) => e.id == id);
    });
  }

  void _deleteSelected() {
    setState(() {
      _displayData.removeWhere((e) => e.isSelected);
      _allData.removeWhere((e) => e.isSelected);
    });
  }

  // --- MODAL FORM ---
  void _showFormModal(BuildContext context, JabatanFormType type, {JabatanModel? item}) {
    final jabatanCtrl = TextEditingController(text: item?.namaJabatan ?? '');
    final namaCtrl = TextEditingController(text: item?.namaPejabat ?? '');
    final nrpCtrl = TextEditingController(text: item?.nrp ?? '');
    final tglCtrl = TextEditingController(text: item?.tanggalPeresmian ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: JabatanFormWidget(
              type: type,
              jabatanController: jabatanCtrl,
              namaController: namaCtrl,
              nrpController: nrpCtrl,
              tanggalController: tglCtrl,
              onCancel: () => Navigator.pop(ctx),
              onSubmit: () {
                if (type == JabatanFormType.add) {
                  _addNewData(
                    jabatanCtrl.text,
                    namaCtrl.text,
                    nrpCtrl.text,
                    tglCtrl.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data Berhasil Ditambah")),
                  );
                } else {
                  if (item != null) {
                    _deleteSingle(item.id);
                  } else {
                    _deleteSelected();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data Berhasil Dihapus")),
                  );
                }
                Navigator.pop(ctx);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: JabatanSearchBar(
                        controller: _searchController,
                        onChanged: (value) => _runSearch(value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: JabatanActionButtons(
                        onAdd: () => _showFormModal(context, JabatanFormType.add),
                        onDelete: () {
                          if (_selectedCount > 0) {
                            _deleteSelected();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("$_selectedCount data dihapus")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Pilih data yang ingin dihapus")),
                            );
                          }
                        },
                        onRefresh: () {
                          _isLoading = true;
                          setState(() {});
                          _loadData();
                          _searchController.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          JabatanListHeader(
            isChecked: _isAllSelected,
            onCheckChanged: (val) => _toggleSelectAll(val),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayData.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _displayData.length,
                        itemBuilder: (context, index) {
                          final item = _displayData[index];
                          return JabatanListItem(
                            item: item,
                            onToggleSelection: () => _toggleSingleSelection(item.id),
                            onEdit: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Edit: ${item.namaJabatan}")),
                              );
                            },
                            onDelete: () => _showFormModal(
                              context,
                              JabatanFormType.delete,
                              item: item,
                            ),
                          );
                        },
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
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
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