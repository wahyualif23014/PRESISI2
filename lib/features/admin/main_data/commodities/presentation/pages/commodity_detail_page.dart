import 'package:flutter/material.dart';
import '../../data/models/commodity_model.dart';
import '../../data/services/commodity_service.dart';

class CommodityDetailPage extends StatefulWidget {
  final String kindName;

  const CommodityDetailPage({super.key, required this.kindName});

  @override
  State<CommodityDetailPage> createState() => _CommodityDetailPageState();
}

class _CommodityDetailPageState extends State<CommodityDetailPage> {
  final CommodityService _service = CommodityService();
  final TextEditingController _searchController = TextEditingController();

  List<CommodityModel> _items = [];
  List<CommodityModel> _filteredItems = []; // Untuk hasil pencarian
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Logika Pencarian
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _items;
      } else {
        _filteredItems =
            _items.where((item) {
              return item.name.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    final data = await _service.fetchCommoditiesByKind(widget.kindName);
    if (mounted) {
      setState(() {
        _items = data;
        _filteredItems = data; // Init data filter
        _isLoading = false;
      });
    }
  }

  // --- LOGIKA HAPUS 1 ITEM ---
  Future<void> _deleteItem(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Hapus Tanaman"),
            content: Text("Yakin ingin menghapus '$name'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Hapus",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final success = await _service.deleteCommodityItem(id);
      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Item berhasil dihapus")));
        _fetchItems(); // Refresh data
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal menghapus item")));
      }
    }
  }

  // --- LOGIKA TAMBAH & EDIT ---
  void _showFormDialog({CommodityModel? item}) {
    final isEdit = item != null;
    final TextEditingController nameController = TextEditingController(
      text: isEdit ? item.name : "",
    );
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? "Edit Tanaman" : "Tambah Tanaman"),
              content: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Tanaman",
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                  ),
                  onPressed:
                      isSaving
                          ? null
                          : () async {
                            if (nameController.text.trim().isEmpty) return;

                            setDialogState(() => isSaving = true);

                            bool success;
                            if (isEdit) {
                              success = await _service.updateCommodity(
                                item.id,
                                nameController.text.trim(),
                              );
                            } else {
                              success = await _service.addCommodity(
                                widget.kindName,
                                nameController.text.trim(),
                              );
                            }

                            if (mounted) {
                              Navigator.pop(context);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEdit
                                          ? "Berhasil diupdate"
                                          : "Berhasil ditambahkan",
                                    ),
                                  ),
                                );
                                _searchController
                                    .clear(); // Clear search saat tambah/edit
                                _fetchItems();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Gagal menyimpan data"),
                                  ),
                                );
                              }
                            }
                          },
                  child:
                      isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            "Simpan",
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.kindName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // BODY MENGGUNAKAN COLUMN AGAR ADA SEARCH DI ATAS
      body: Column(
        children: [
          // 1. BAGIAN SEARCH BAR & ADD BUTTON
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Cari Tanaman...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Tombol Tambah (Icon Box)
                InkWell(
                  onTap: () => _showFormDialog(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981), // Warna Hijau
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),

          // 2. LIST DATA
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredItems.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _items.isEmpty
                                ? "Belum ada data ${widget.kindName}"
                                : "Tidak ditemukan",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE0F2FE),
                              child: Text(
                                item.name.isNotEmpty
                                    ? item.name[0].toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                  color: Color(0xFF0284C7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              "Jenis: ${item.categoryId}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showFormDialog(item: item);
                                } else if (value == 'delete') {
                                  _deleteItem(item.id, item.name);
                                }
                              },
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 8),
                                          Text("Edit"),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text("Hapus"),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
