import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/data/repos/commodity_item_repository.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/presentation/widgets/commodity_list_item.dart';
import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/data/repos/commodity_category_repository.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/presentation/widgets/comoditiy_search.dart';

// Import Model
import 'data/models/commodity_category_model.dart';
// Import Widget
import 'presentation/widgets/comodity_banner.dart';
import 'presentation/widgets/commodity_category_card.dart';
// Import Halaman Detail

// IMPORT WIDGET FORM BARU DISINI
import 'presentation/widgets/commodity_form_dialog.dart'; 

class ComoditiesPage extends StatefulWidget {
  const ComoditiesPage({super.key});

  @override
  State<ComoditiesPage> createState() => _ComoditiesPageState();
}

class _ComoditiesPageState extends State<ComoditiesPage> {
  final TextEditingController _searchController = TextEditingController();

  List<CommodityCategoryModel> _allData = [];
  List<CommodityCategoryModel> _displayData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final data = CommodityRepository.getCategoryData();
    setState(() {
      _allData = data;
      _displayData = List.from(data);
    });
  }

  void _runSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayData = List.from(_allData);
      } else {
        _displayData = _allData.where((item) {
          return item.title.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToDetail(CommodityCategoryModel item) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => CommodityListPage(category: item),
      ),
    );
  }

  // --- FUNGSI 1: TAMPILKAN DIALOG TAMBAH ---
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CommodityFormDialog(
          isEdit: false, // Mode Tambah
          onCancel: () => Navigator.pop(context),
          onConfirm: (name, desc) {
            // Logika simpan data baru disini
            print("Simpan Baru: $name");
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("Data Berhasil Ditambahkan")),
            );
          },
        );
      },
    );
  }

  // --- FUNGSI 2: TAMPILKAN DIALOG EDIT ---
  // Fungsi ini bisa dipanggil ketika user menekan tombol edit pada card/list
  void _showEditDialog(CommodityCategoryModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return CommodityFormDialog(
          isEdit: true, // Mode Edit
          initialName: item.title, // Isi data awal
          initialDescription: item.description,
          onCancel: () => Navigator.pop(context),
          onConfirm: (name, desc) {
            // Logika update data disini
            print("Update Data: $name");
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("Data Berhasil Diubah")),
            );
          },
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
      backgroundColor: const Color(0xFFE0E0E0),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ComoditiSearch(
              controller: _searchController,
              onChanged: _runSearch,
              // Panggil Fungsi Tambah Disini
              onAdd: _showAddDialog, 
              onDelete: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fitur Hapus Data")),
                );
              },
            ),
          ),

          // 2. Banner
          ComoditiyBanner(
            totalTypes: _displayData.length,
            totalItems: 0,
            onClose: () {},
          ),

          const SizedBox(height: 16),

          // 3. List Category Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _displayData.length,
              itemBuilder: (context, index) {
                final item = _displayData[index];

                return GestureDetector(
                  // Contoh: Tekan lama untuk Edit (Opsional, atau tambahkan tombol edit di Card)
                  onLongPress: () => _showEditDialog(item),
                  child: CommodityCategoryCard(
                    item: item,
                    onViewAllTap: () => _navigateToDetail(item),
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