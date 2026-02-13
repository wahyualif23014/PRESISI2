import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/providers/CommodityProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/commodity_category_model.dart';
import '../../data/models/commodity_model.dart';

class CommodityListPage extends StatefulWidget {
  final CommodityCategoryModel category;

  const CommodityListPage({super.key, required this.category});

  @override
  State<CommodityListPage> createState() => _CommodityListPageState();
}

class _CommodityListPageState extends State<CommodityListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CommodityModel> _filteredItems = [];
  bool _isAllSelected = false;
  final Set<String> _selectedIds = {}; // Mengelola seleksi berdasarkan ID

  @override
  void initState() {
    super.initState();
    // Load data melalui Provider
    Future.microtask(() =>
        context.read<CommodityProvider>().fetchItemsByKind(widget.category.title));
  }

  // --- LOGIC AREA ---

  void _runSearch(String query, List<CommodityModel> allItems) {
    setState(() {
      _filteredItems = allItems
          .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleItemSelection(String id, bool? value) {
    setState(() {
      if (value == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
      // Update status "Select All"
      final currentItems = _searchController.text.isEmpty 
          ? context.read<CommodityProvider>().items 
          : _filteredItems;
      _isAllSelected = currentItems.isNotEmpty && 
                       currentItems.every((item) => _selectedIds.contains(item.id));
    });
  }

  void _toggleSelectAll(bool? value, List<CommodityModel> currentItems) {
    setState(() {
      _isAllSelected = value ?? false;
      if (_isAllSelected) {
        for (var item in currentItems) {
          _selectedIds.add(item.id);
        }
      } else {
        _selectedIds.clear();
      }
    });
  }

  Future<void> _deleteSelectedItems() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih item yang ingin dihapus terlebih dahulu")),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Data"),
        content: Text("Apakah Anda yakin ingin menghapus ${_selectedIds.length} item terpilih?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = context.read<CommodityProvider>();
      // Proses hapus satu per satu melalui Provider
      for (var id in _selectedIds) {
        await provider.deleteItem(widget.category.title, id);
      }
      
      setState(() {
        _selectedIds.clear();
        _isAllSelected = false;
        _searchController.clear();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data berhasil dihapus")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
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
      body: Consumer<CommodityProvider>(
        builder: (context, provider, child) {
          final items = _searchController.text.isEmpty ? provider.items : _filteredItems;

          return Column(
            children: [
              // 1. Search Bar & Action Buttons Area
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFF5F5F5),
                child: Row(
                  children: [
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
                          onChanged: (v) => _runSearch(v, provider.items),
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
                    _buildActionButton(
                      label: "Add",
                      icon: Icons.add,
                      color: const Color(0xFF00ACC1),
                      onTap: () {
                        // Navigasi atau Dialog Tambah
                      },
                    ),
                    const SizedBox(width: 8),
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
                    SizedBox(
                      width: 24, height: 24,
                      child: Checkbox(
                        value: _isAllSelected,
                        onChanged: (val) => _toggleSelectAll(val, items),
                        activeColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text("NAMA KOMODITI LAHAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const Text("AKSI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),

              // 3. Header Category Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    const Icon(Icons.grass, size: 20),
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
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                        ? const Center(child: Text("Tidak ada data ditemukan"))
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final isSelected = _selectedIds.contains(item.id);
                              return _buildRowItem(item, isSelected);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRowItem(CommodityModel item, bool isSelected) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24, height: 24,
            child: Checkbox(
              value: isSelected,
              onChanged: (val) => _toggleItemSelection(item.id, val),
              side: const BorderSide(color: Colors.purple),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () { /* Edit logic */ },
                child: const Icon(Icons.edit_square, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () async {
                  await context.read<CommodityProvider>().deleteItem(widget.category.title, item.id);
                },
                child: const Icon(Icons.delete, color: Colors.red, size: 20),
              ),
            ],
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