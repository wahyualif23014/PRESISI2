// Lokasi: lib/features/admin/main_data/jabatan/pages/jabatan_page.dart

import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/main_data/positions/data/models/position_model.dart';
import 'package:sdmapp/features/admin/main_data/positions/data/models/position_repository.dart';

// HAPUS import provider
// import 'package:provider/provider.dart';
// import 'package:sdmapp/features/admin/main_data/positions/data/providers/jabatan_provider.dart';

// Tetap gunakan Model dan Repository untuk data dummy


// Widget UI
import 'package:sdmapp/features/admin/main_data/positions/presentation/widgets/jabatan_action_buttons.dart';
import 'package:sdmapp/features/admin/main_data/positions/presentation/widgets/jabatan_list_header.dart';
import 'package:sdmapp/features/admin/main_data/positions/presentation/widgets/jabatan_list_item.dart';
import 'package:sdmapp/features/admin/main_data/positions/presentation/widgets/jabatan_search_bar.dart';

class PositionPage extends StatefulWidget {
  const PositionPage({super.key});

  @override
  State<PositionPage> createState() => _PositionPageState();
}

class _PositionPageState extends State<PositionPage> {
  final TextEditingController _searchController = TextEditingController();

  // --- LOCAL STATE (Pengganti Provider Sementara) ---
  List<JabatanModel> _allData = [];      // Data Master
  List<JabatanModel> _displayData = [];  // Data yang Tampil (terfilter)

  @override
  void initState() {
    super.initState();
    // Load data langsung dari Repository (Tanpa Provider)
    _loadLocalData();
  }

  void _loadLocalData() {
    setState(() {
      _allData = JabatanRepository.getDummyData();
      _displayData = List.from(_allData);
    });
  }

  // Logic Search Lokal
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

  // Logic Select All Lokal
  void _toggleSelectAll(bool? val) {
    setState(() {
      if (val != null) {
        for (var item in _displayData) {
          item.isSelected = val;
        }
      }
    });
  }

  // Logic Select Single Lokal
  void _toggleSingleSelection(String id) {
    setState(() {
      final index = _displayData.indexWhere((e) => e.id == id);
      if (index != -1) {
        _displayData[index].isSelected = !_displayData[index].isSelected;
      }
    });
  }

  // Logic Delete Selected Lokal
  void _deleteSelected() {
    setState(() {
      // Hapus dari data tampil & master data
      _displayData.removeWhere((element) => element.isSelected);
      _allData.removeWhere((element) => element.isSelected);
    });
  }

  // Logic Delete Single Lokal
  void _deleteSingle(String id) {
    setState(() {
      _displayData.removeWhere((element) => element.id == id);
      _allData.removeWhere((element) => element.id == id);
    });
  }

  // Hitung jumlah yang dipilih
  int get _selectedCount => _displayData.where((e) => e.isSelected).length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Logic "Select All" Checkbox State
    final isAllSelected = _displayData.isNotEmpty && 
        _displayData.length == _selectedCount;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // -------------------------------------------------------
          // 1. BAGIAN ATAS (Header Controls)
          // -------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    // Search Bar
                    Expanded(
                      flex: 4,
                      child: JabatanSearchBar(
                        controller: _searchController,
                        onChanged: (value) => _runSearch(value), // Panggil fungsi lokal
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Action Buttons
                    Expanded(
                      flex: 6,
                      child: JabatanActionButtons(
                        onAdd: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fitur Add (UI Only)")),
                          );
                        },
                        onDelete: () {
                          if (_selectedCount > 0) {
                             _deleteSelected(); // Panggil fungsi lokal
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Data dihapus sementara")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Pilih data dulu")),
                            );
                          }
                        },
                        onRefresh: () {
                          _loadLocalData(); // Reset data
                          _searchController.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // -------------------------------------------------------
          // 2. LIST HEADER
          // -------------------------------------------------------
          JabatanListHeader(
            isChecked: isAllSelected,
            onCheckChanged: (val) => _toggleSelectAll(val),
          ),

          // -------------------------------------------------------
          // 3. LIST DATA
          // -------------------------------------------------------
          Expanded(
            child: _displayData.isEmpty
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
                            SnackBar(content: Text("Edit ${item.namaJabatan}")),
                          );
                        },
                        onDelete: () => _deleteSingle(item.id),
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