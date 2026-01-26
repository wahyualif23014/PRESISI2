import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/main_data/commodities/data/repos/commodity_category_repository.dart';
import 'package:sdmapp/features/admin/main_data/commodities/presentation/widgets/comoditiy_search.dart';

// Import Model, Repo, dan Widget Baru
import 'data/models/commodity_category_model.dart';
import 'presentation/widgets/comodity_banner.dart';
import 'presentation/widgets/commodity_category_card.dart';

class ComoditiesPage extends StatefulWidget {
  const ComoditiesPage({super.key});

  @override
  State<ComoditiesPage> createState() => _ComoditiesPageState();
}

class _ComoditiesPageState extends State<ComoditiesPage> {
  final TextEditingController _searchController = TextEditingController();

  // Menggunakan Model Kategori Baru
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
    // TODO: Implementasi navigasi ke halaman detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Membuka detail: ${item.title}")),
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
      backgroundColor: const Color(0xFFE0E0E0), // Abu-abu agar card terlihat timbul
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ComoditiSearch(
              controller: _searchController,
              onChanged: _runSearch,
              onAdd: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fitur Tambah Data")),
                );
              },
              onDelete: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fitur Hapus Data")),
                );
              },
            ),
          ),

          // 2. Banner (Tetap dipertahankan sesuai request)
          ComoditiyBanner(
            totalTypes: _displayData.length, // Menghitung jumlah kategori
            totalItems: 0, // Bisa disesuaikan jika ada data total sub-item
            onClose: () {},
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _displayData.length,
              itemBuilder: (context, index) {
                final item = _displayData[index];
                
                // Memanggil Widget Card Baru
                return CommodityCategoryCard(
                  item: item,
                  onViewAllTap: () => _navigateToDetail(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}