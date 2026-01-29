// Lokasi: lib/features/admin/main_data/wilayah/pages/regions_page.dart

import 'package:flutter/material.dart';

// Data
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/data/models/region_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/data/repos/region_repository.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_filter_widget.dart';

// Widgets
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_info_banner.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_search_filter.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_table_header.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_list_item.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_group_headers.dart';

class RegionsPage extends StatefulWidget {
  const RegionsPage({super.key});

  @override
  State<RegionsPage> createState() => _RegionsPageState();
}

class _RegionsPageState extends State<RegionsPage> {
  // Controller Search
  final TextEditingController _searchController = TextEditingController();

  // Data State
  List<WilayahModel> _allData = [];
  List<WilayahModel> _displayData = [];
  bool _isBannerVisible = true;

  final Set<String> _expandedKabupaten = {};
  final Set<String> _expandedKecamatan = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final data = WilayahRepository.getDummyData();

    // Sorting wajib agar grouping berurutan
    data.sort((a, b) {
      int kabCmp = a.kabupaten.compareTo(b.kabupaten);
      if (kabCmp != 0) return kabCmp;
      return a.kecamatan.compareTo(b.kecamatan);
    });

    setState(() {
      _allData = data;
      _displayData = List.from(data);

      // Default: Buka semua data saat pertama kali load
      // (Opsional: Hapus blok ini jika ingin default tertutup)
      for (var item in data) {
        _expandedKabupaten.add(item.kabupaten);
        _expandedKecamatan.add(item.kecamatan);
      }
    });
  }

  void _runSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayData = List.from(_allData);
      } else {
        _displayData =
            _allData.where((item) {
              return item.namaDesa.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  item.kecamatan.toLowerCase().contains(query.toLowerCase()) ||
                  item.kabupaten.toLowerCase().contains(query.toLowerCase());
            }).toList();

        // Saat search, otomatis buka semua yang relevan agar hasil terlihat
        for (var item in _displayData) {
          _expandedKabupaten.add(item.kabupaten);
          _expandedKecamatan.add(item.kecamatan);
        }
      }
    });
  }

  // Fungsi Toggle Kabupaten
  void _toggleKabupaten(String namaKab) {
    setState(() {
      if (_expandedKabupaten.contains(namaKab)) {
        _expandedKabupaten.remove(namaKab); // Tutup
      } else {
        _expandedKabupaten.add(namaKab); // Buka
      }
    });
  }

  // Fungsi Toggle Kecamatan
  void _toggleKecamatan(String namaKec) {
    setState(() {
      if (_expandedKecamatan.contains(namaKec)) {
        _expandedKecamatan.remove(namaKec); // Tutup
      } else {
        _expandedKecamatan.add(namaKec); // Buka
      }
    });
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
          // 1. SEARCH & FILTER
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: WilayahSearchFilter(
              controller: _searchController,
              onChanged: _runSearch,
              onFilterTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return WilayahFilterWidget(
                      onApply: () {
                        // TODO: Masukkan logika filter data di sini
                        Navigator.pop(context); // Tutup popup
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Filter diterapkan")),
                        );
                      },
                      onReset: () {
                        // TODO: Masukkan logika reset data di sini
                        // (Popup tidak perlu ditutup jika ingin user lihat checkbox kereset)
                      },
                    );
                  },
                );
              },
            ),
          ),

          // 2. INFO BANNER
          if (_isBannerVisible)
            WilayahInfoBanner(
              totalCount: _displayData.length,
              onClose: () => setState(() => _isBannerVisible = false),
            ),

          // 3. TABLE HEADER
          const WilayahTableHeader(),

          // 4. LIST DATA (Grouped with Logic)
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _displayData.length,
              itemBuilder: (context, index) {
                final item = _displayData[index];

                // --- DETEKSI HEADER ---
                bool isNewKabupaten = false;
                bool isNewKecamatan = false;

                if (index == 0) {
                  isNewKabupaten = true;
                  isNewKecamatan = true;
                } else {
                  final prevItem = _displayData[index - 1];
                  if (prevItem.kabupaten != item.kabupaten) {
                    isNewKabupaten = true;
                    isNewKecamatan = true;
                  } else if (prevItem.kecamatan != item.kecamatan) {
                    isNewKecamatan = true;
                  }
                }

                // --- LOGIC VISIBILITY (PENTING) ---

                // 1. Cek Status Kabupaten (Buka/Tutup)
                final isKabOpen = _expandedKabupaten.contains(item.kabupaten);

                final isKecOpen =
                    isKabOpen && _expandedKecamatan.contains(item.kecamatan);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // A. HEADER KABUPATEN
                    if (isNewKabupaten)
                      WilayahKabupatenHeader(
                        title: item.kabupaten,
                        isExpanded: isKabOpen,
                        onTap: () => _toggleKabupaten(item.kabupaten),
                      ),

                    // B. HEADER KECAMATAN
                    // Hanya tampil jika Header baru DAN Kabupaten induknya terbuka
                    if (isNewKecamatan && isKabOpen)
                      WilayahKecamatanHeader(
                        title: item.kecamatan,
                        isExpanded: isKecOpen,
                        onTap: () => _toggleKecamatan(item.kecamatan),
                      ),

                    // C. DATA ROW (DESA)
                    // Hanya tampil jika Kecamatan induknya terbuka
                    if (isKecOpen)
                      WilayahListItem(
                        item: item,
                        onEditTap: () {
                          // Handle Edit
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
}
