import 'package:flutter/material.dart';
import '../../data/models/commodity_category_model.dart';
import '../../data/models/commodity_model.dart';
import '../../data/repos/commodity_item_repository.dart';

class CommodityListPage extends StatefulWidget {
  final CommodityCategoryModel category;

  const CommodityListPage({super.key, required this.category});

  @override
  State<CommodityListPage> createState() => _CommodityListPageState();
}

class _CommodityListPageState extends State<CommodityListPage> {
  // State Variables
  List<CommodityModel> _allItems = [];
  List<CommodityModel> _displayItems = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isAllSelected = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Simulasi fetch data dari Repository
    final data = CommodityRepository.getCommoditiesByCategory(widget.category.id);
    setState(() {
      _allItems = data;
      _displayItems = List.from(data);
    });
  }

  // --- LOGIC AREA (Controller-like functions) ---

  void _runSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayItems = List.from(_allItems);
      } else {
        _displayItems = _allItems
            .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleItemSelection(int index, bool? value) {
    setState(() {
      // Update item spesifik menggunakan copyWith (Immutable update)
      _displayItems[index] = _displayItems[index].copyWith(isSelected: value);
      
      // Update data master juga agar sinkron saat search dibersihkan
      final masterIndex = _allItems.indexWhere((element) => element.id == _displayItems[index].id);
      if (masterIndex != -1) {
        _allItems[masterIndex] = _allItems[masterIndex].copyWith(isSelected: value);
      }

      // Cek apakah semua sudah terpilih untuk update header checkbox
      _isAllSelected = _displayItems.every((item) => item.isSelected);
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _isAllSelected = value ?? false;
      for (int i = 0; i < _displayItems.length; i++) {
        _displayItems[i] = _displayItems[i].copyWith(isSelected: _isAllSelected);
      }
      // Update master data
       for (int i = 0; i < _allItems.length; i++) {
        _allItems[i] = _allItems[i].copyWith(isSelected: _isAllSelected);
      }
    });
  }

  void _deleteSelectedItems() {
    // Validasi sederhana
    final selectedCount = _allItems.where((e) => e.isSelected).length;
    if (selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih item yang ingin dihapus terlebih dahulu")),
      );
      return;
    }

    // Tampilkan Dialog Konfirmasi
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Data"),
        content: Text("Apakah Anda yakin ingin menghapus $selectedCount item terpilih?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _allItems.removeWhere((item) => item.isSelected);
                _runSearch(_searchController.text); // Refresh display list
                _isAllSelected = false;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B), // Warna header gelap seperti gambar
        leading: IconButton(
          icon: Container(
             padding: const EdgeInsets.all(4),
             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
             child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.category.title.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
        ),
      ),
      body: Column(
        children: [
          // 1. Search Bar & Action Buttons Area
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF5F5F5),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _runSearch,
                      decoration: const InputDecoration(
                        hintText: "Cari Data",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Add Button
                _buildActionButton(
                  label: "Add",
                  icon: Icons.add,
                  color: const Color(0xFF00ACC1),
                  onTap: () {
                     // TODO: Navigasi ke Form Tambah
                  },
                ),
                const SizedBox(width: 8),
                // Delete Button
                _buildActionButton(
                  label: "Delete",
                  icon: Icons.delete,
                  color: const Color(0xFFEF5350),
                  onTap: _deleteSelectedItems,
                ),
              ],
            ),
          ),

          // 2. Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade300)),
              color: Colors.white,
            ),
            child: Row(
              children: [
                // Select All Checkbox
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _isAllSelected,
                    onChanged: _toggleSelectAll,
                    activeColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "NAMA KOMODITI LAHAN",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const Text(
                  "AKSI",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),

          // 3. Header Category Title (Sub-header visual seperti di gambar)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Icon(Icons.grass, size: 20), // Ikon tanaman
                const SizedBox(width: 8),
                Text(
                  widget.category.title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ],
            ),
          ),

          // 4. List View
          Expanded(
            child: ListView.separated(
              itemCount: _displayItems.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _displayItems[index];
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: item.isSelected,
                          onChanged: (val) => _toggleItemSelection(index, val),
                          side: const BorderSide(color: Colors.purple), // Sesuai warna di gambar (ungu tipis)
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      // Action Icons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                               // TODO: Edit Action
                            },
                            child: const Icon(Icons.edit_square, color: Colors.blue, size: 20)
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                               // TODO: Single Delete Action
                            },
                            child: const Icon(Icons.delete, color: Colors.red, size: 20)
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        minimumSize: Size.zero, 
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}