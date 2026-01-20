// Lokasi: lib/features/admin/main_data/commodities/comodities.dart

import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/main_data/commodities/presentation/widgets/comoditiy_search.dart';

// 1. IMPORT DATA & MODEL
import 'data/models/commodity_model.dart';
import './data/models/commodity_repository.dart';

import 'presentation/widgets/comodity_banner.dart';  // Sesuaikan nama file banner Anda
import 'presentation/widgets/commodity_group_header.dart';
import 'presentation/widgets/commodity_list_item.dart';

class ComoditiesPage extends StatefulWidget {
  const ComoditiesPage({super.key});

  @override
  State<ComoditiesPage> createState() => _ComoditiesPageState();
}

class _ComoditiesPageState extends State<ComoditiesPage> {
  // Controller Search
  final TextEditingController _searchController = TextEditingController();

  // Data State
  List<CommodityModel> _allData = [];
  List<CommodityModel> _displayData = [];
  
  // State untuk Grouping (Menyimpan Tipe Tanaman yang sedang Terbuka)
  final Set<String> _expandedTypes = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final data = CommodityRepository.getDummyData();

    // 1. Sorting Wajib: Urutkan berdasarkan Tipe dulu, baru Nama
    // Ini PENTING agar grouping tidak berantakan
    data.sort((a, b) {
      int typeCmp = a.type.compareTo(b.type);
      if (typeCmp != 0) return typeCmp;
      return a.name.compareTo(b.name);
    });

    setState(() {
      _allData = data;
      _displayData = List.from(data);

      // 2. Default: Buka semua group saat pertama load
      for (var item in data) {
        _expandedTypes.add(item.type);
      }
    });
  }

  // Logic Pencarian
  void _runSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayData = List.from(_allData);
      } else {
        _displayData = _allData.where((item) {
          return item.name.toLowerCase().contains(query.toLowerCase()) ||
                 item.type.toLowerCase().contains(query.toLowerCase());
        }).toList();

        // Saat search, buka semua group agar hasil terlihat
        for (var item in _displayData) {
          _expandedTypes.add(item.type);
        }
      }
    });
  }

  // Logic Toggle Group (Buka/Tutup Header)
  void _toggleGroup(String type) {
    setState(() {
      if (_expandedTypes.contains(type)) {
        _expandedTypes.remove(type);
      } else {
        _expandedTypes.add(type);
      }
    });
  }

  // Logic Select All (Checkbox Master)
  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value != null) {
        for (var item in _displayData) {
          item.isSelected = value;
        }
      }
    });
  }

  // Logic Select Single Item
  void _toggleSingleItem(String id) {
    setState(() {
      final index = _displayData.indexWhere((e) => e.id == id);
      if (index != -1) {
        _displayData[index].isSelected = !_displayData[index].isSelected;
      }
    });
  }

  // Helper untuk menghitung jumlah Jenis Komoditi (Group)
  int get _totalTypes {
    return _displayData.map((e) => e.type).toSet().length;
  }

  // Helper untuk cek status "Select All"
  bool get _isAllSelected {
    return _displayData.isNotEmpty && _displayData.every((e) => e.isSelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ------------------------------------------------
          // 1. SEARCH & BUTTONS
          // ------------------------------------------------
          // Menggunakan widget search yang sudah Anda buat
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ComoditiSearch( // Sesuaikan nama class widget search Anda
              controller: _searchController,
              onChanged: _runSearch,
              onAdd: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tambah Data")),
                );
              },
              onDelete: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hapus Data Terpilih")),
                );
              },
            ),
          ),

          // ------------------------------------------------
          // 2. INFO BANNER
          // ------------------------------------------------
          // Menggunakan widget banner yang sudah Anda buat
          ComoditiyBanner( // Sesuaikan nama class widget banner Anda
            totalTypes: _totalTypes,        // Jumlah Jenis (Group)
            totalItems: _displayData.length, // Jumlah Total Item
            onClose: () {},
          ),

          // ------------------------------------------------
          // 3. TABLE HEADER (Static Row)
          // ------------------------------------------------
          _buildTableHeader(),

          // ------------------------------------------------
          // 4. LIST DATA (Grouped)
          // ------------------------------------------------
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _displayData.length,
              itemBuilder: (context, index) {
                final item = _displayData[index];

                // --- LOGIC DETEKSI HEADER BARU ---
                bool isNewGroup = false;
                if (index == 0) {
                  isNewGroup = true;
                } else {
                  final prevItem = _displayData[index - 1];
                  if (prevItem.type != item.type) {
                    isNewGroup = true;
                  }
                }

                // Cek apakah group ini sedang terbuka?
                final isGroupOpen = _expandedTypes.contains(item.type);

                return Column(
                  children: [
                    // A. HEADER GROUP (Muncul sekali tiap jenis)
                    if (isNewGroup)
                      CommodityGroupHeader(
                        title: item.type,
                        isExpanded: isGroupOpen,
                        onTap: () => _toggleGroup(item.type),
                      ),

                    // B. LIST ITEM
                    // Hanya dirender jika group-nya terbuka
                    if (isGroupOpen)
                      CommodityListItem(
                        item: item,
                        onToggleSelection: () => _toggleSingleItem(item.id),
                        onEditTap: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Edit ${item.name}")),
                          );
                        },
                        onDeleteTap: () {
                          // Logic delete single
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Header Tabel (Checkbox Master & Judul Kolom)
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5), // Abu-abu sangat muda
        border: Border(
          bottom: BorderSide(color: Colors.black12),
          top: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          // Master Checkbox
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: _isAllSelected,
              onChanged: _toggleSelectAll,
              activeColor: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          
          // Label Judul
          const Expanded(
            child: Text(
              "NAMA KOMODITI LAHAN",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ),

          // Label Proses
          const Text(
            "PROSES",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 16), // Padding kanan agar lurus dengan icon delete/edit
        ],
      ),
    );
  }
}