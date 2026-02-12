import 'package:flutter/material.dart';

// --- IMPORT MODELS ---
import '../../data/models/commodity_category_model.dart';

// --- IMPORT SERVICE ---
import '../../data/services/commodity_service.dart';

// --- IMPORT WIDGETS ---
// import '../widgets/commodity_search.dart'; // Tidak perlu lagi karena kita custom langsung
import '../widgets/commodity_banner.dart';

// --- IMPORT PAGES ---
import 'commodity_detail_page.dart';

class ComoditiesPage extends StatefulWidget {
  const ComoditiesPage({super.key});

  @override
  State<ComoditiesPage> createState() => _ComoditiesPageState();
}

class _ComoditiesPageState extends State<ComoditiesPage> {
  final TextEditingController _searchController = TextEditingController();
  final CommodityService _service = CommodityService();

  List<CommodityCategoryModel> _allCategories = [];
  List<CommodityCategoryModel> _displayCategories = [];

  // STATE UNTUK BANNER
  int _totalCategoriesCount = 0; // Hitung dari jumlah card
  int _totalItemsCount = 0; // Hitung dari database backend

  bool _isLoading = true;

  // Selection Mode State (Untuk Hapus)
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    // Panggil Service Baru
    final result = await _service.fetchCategoriesData();

    if (mounted) {
      setState(() {
        _allCategories = result.categories;
        _displayCategories = result.categories;

        // --- UPDATE DATA BANNER ---
        _totalCategoriesCount = result.categories.length; // Jumlah Jenis
        _totalItemsCount = result.totalItems; // Jumlah Tanaman DB
        // --------------------------

        _isLoading = false;

        // Reset Selection setiap refresh
        _isSelectionMode = false;
        _selectedItems.clear();
      });
    }
  }

  void _runSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayCategories = _allCategories;
      } else {
        _displayCategories =
            _allCategories
                .where(
                  (item) =>
                      item.title.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  // --- LOGIKA DELETE (MULTI SELECT) ---
  void _toggleSelection(String title) {
    setState(() {
      if (_selectedItems.contains(title)) {
        _selectedItems.remove(title);
        if (_selectedItems.isEmpty) _isSelectionMode = false;
      } else {
        _selectedItems.add(title);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Hapus Komoditas"),
            content: Text(
              "Hapus ${_selectedItems.length} kategori terpilih? Semua data tanaman di dalamnya akan terhapus.",
            ),
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

    if (shouldDelete == true) {
      setState(() => _isLoading = true);

      // Loop hapus item terpilih
      for (var kind in _selectedItems) {
        await _service.deleteCategory(kind);
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Data berhasil dihapus")));
        _fetchData(); // Refresh data setelah hapus
      }
    }
  }

  // --- LOGIKA SHOW ADD DIALOG ---
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCommodityDialog(),
    ).then((value) {
      if (value == true) _fetchData(); // Refresh jika ada data baru disimpan
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // AppBar Muncul HANYA saat Mode Seleksi
      appBar:
          _isSelectionMode
              ? AppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed:
                      () => setState(() {
                        _isSelectionMode = false;
                        _selectedItems.clear();
                      }),
                ),
                title: Text(
                  "${_selectedItems.length} Dipilih",
                  style: const TextStyle(color: Colors.black),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteSelected,
                  ),
                ],
                elevation: 1,
              )
              : null,

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tampilkan Search & Banner jika BUKAN mode seleksi
                        if (!_isSelectionMode) ...[
                          const SizedBox(height: 10),

                          // --- BAGIAN SEARCH & BUTTON HIJAU (CUSTOM) ---
                          Row(
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
                                    onChanged: _runSearch,
                                    decoration: const InputDecoration(
                                      hintText: "Cari Komoditas disini",
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Tombol Tambah (HIJAU)
                              InkWell(
                                onTap: _showAddDialog,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ), // WARNA HIJAU
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // ---------------------------------------------
                          const SizedBox(height: 24),

                          // --- BANNER DENGAN 2 DATA ---
                          CommodityBanner(
                            totalCategories: _totalCategoriesCount,
                            totalItems: _totalItemsCount,
                          ),

                          // ----------------------------
                          const SizedBox(height: 24),
                          const Text(
                            "Kategori Komoditas",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Tekan lama untuk menghapus",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // List Data
                        _displayCategories.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _displayCategories.length,
                              separatorBuilder:
                                  (c, i) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return _buildCategoryCard(
                                  _displayCategories[index],
                                );
                              },
                            ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  // --- BUILD CARD UTAMA ---
  Widget _buildCategoryCard(CommodityCategoryModel item) {
    final categoryStyle = _getCategoryStyle(item.title);
    final isSelected = _selectedItems.contains(item.title);

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _isSelectionMode = true;
          _toggleSelection(item.title);
        });
      },
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(item.title);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommodityDetailPage(kindName: item.title),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE5E7EB).withOpacity(0.6),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: categoryStyle.bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      categoryStyle.icon,
                      color: categoryStyle.iconColor,
                      size: 30,
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Data komoditas untuk sektor ${item.title.toLowerCase()}.",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isSelectionMode)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Style Warna Warni
  _CategoryStyle _getCategoryStyle(String title) {
    final t = title.toLowerCase();
    if (t.contains('pangan'))
      return _CategoryStyle(
        icon: Icons.grass,
        bgColor: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFD97706),
      );
    if (t.contains('hortikultura') || t.contains('sayur'))
      return _CategoryStyle(
        icon: Icons.local_florist,
        bgColor: const Color(0xFFD1FAE5),
        iconColor: const Color(0xFF059669),
      );
    if (t.contains('perkebunan') || t.contains('kebun'))
      return _CategoryStyle(
        icon: Icons.forest,
        bgColor: const Color(0xFFE0E7FF),
        iconColor: const Color(0xFF4F46E5),
      );
    return _CategoryStyle(
      icon: Icons.category,
      bgColor: const Color(0xFFF3F4F6),
      iconColor: const Color(0xFF6B7280),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              "Tidak ada kategori ditemukan",
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// Class Helper Style
class _CategoryStyle {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  _CategoryStyle({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

// --- WIDGET DIALOG TAMBAH DATA (FIXED: NO OVERFLOW) ---
class AddCommodityDialog extends StatefulWidget {
  const AddCommodityDialog({super.key});

  @override
  State<AddCommodityDialog> createState() => _AddCommodityDialogState();
}

class _AddCommodityDialogState extends State<AddCommodityDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();

  // List Dynamic untuk Nama Tanaman
  final List<TextEditingController> _plantControllers = [
    TextEditingController(),
  ];

  bool _isSaving = false;
  final CommodityService _service = CommodityService();

  @override
  void dispose() {
    _categoryController.dispose();
    for (var c in _plantControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addPlantField() {
    setState(() {
      _plantControllers.add(TextEditingController());
    });
  }

  void _removePlantField(int index) {
    if (_plantControllers.length > 1) {
      setState(() {
        _plantControllers[index].dispose();
        _plantControllers.removeAt(index);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final category = _categoryController.text.trim();
    bool allSuccess = true;

    // Loop simpan semua tanaman
    for (var controller in _plantControllers) {
      final plantName = controller.text.trim();
      if (plantName.isNotEmpty) {
        final success = await _service.addCommodity(category, plantName);
        if (!success) allSuccess = false;
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (allSuccess) {
        Navigator.pop(context, true); // Close dialog & refresh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil disimpan!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sebagian data gagal disimpan")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        // Batasi tinggi dialog agar tidak memenuhi layar (Max 80%)
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        // SOLUSI: Bungkus dengan SingleChildScrollView agar bisa discroll saat keyboard muncul
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tambah Komoditas",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Input Jenis Komoditi
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: "Jenis Komoditi",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator:
                        (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "Daftar Tanaman:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  // List Input Tanaman
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _plantControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _plantControllers[index],
                                decoration: InputDecoration(
                                  hintText: "Nama Tanaman ${index + 1}",
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator:
                                    (v) =>
                                        v == null || v.isEmpty
                                            ? "Wajib diisi"
                                            : null,
                              ),
                            ),
                            if (_plantControllers.length > 1)
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removePlantField(index),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Tombol Tambah Field Tanaman
                  TextButton.icon(
                    onPressed: _addPlantField,
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah Nama Lain"),
                  ),

                  const SizedBox(height: 16),

                  // Tombol Aksi (Batal & Simpan)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF10B981,
                          ), // TOMBOL SIMPAN DIALOG JUGA HIJAU
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isSaving
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  "Simpan",
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
