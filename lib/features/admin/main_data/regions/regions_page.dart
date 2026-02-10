import 'package:KETAHANANPANGAN/features/admin/main_data/regions/data/provider/region_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_info_banner.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_search_filter.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_table_header.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_list_item.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_group_headers.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_filter_widget.dart';

class RegionsPage extends StatefulWidget {
  const RegionsPage({super.key});

  @override
  State<RegionsPage> createState() => _RegionsPageState();
}

class _RegionsPageState extends State<RegionsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch data saat init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegionProvider>().fetchRegions();
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
          // 1. SEARCH & FILTER SECTION
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: WilayahSearchFilter(
              controller: _searchController,
              onChanged: (val) => context.read<RegionProvider>().search(val),
              onFilterTap: () {
                showDialog(
                  context: context,
                  builder:
                      (ctx) => WilayahFilterWidget(
                        onApply: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Filter diterapkan")),
                          );
                        },
                        onReset: () {
                          Navigator.pop(ctx);
                        },
                      ),
                );
              },
            ),
          ),

          // 2. CONSUMER UNTUK DATA LIST
          Expanded(
            child: Consumer<RegionProvider>(
              builder: (context, provider, child) {
                // A. LOADING
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // B. ERROR
                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        Text("Error: ${provider.errorMessage}"),
                        ElevatedButton(
                          onPressed: () => provider.refresh(),
                          child: const Text("Coba Lagi"),
                        ),
                      ],
                    ),
                  );
                }

                // C. EMPTY
                if (provider.displayData.isEmpty) {
                  return const Center(
                    child: Text("Data wilayah tidak ditemukan"),
                  );
                }

                // D. DATA LIST
                return Column(
                  children: [
                    // Banner Info (Bisa ditutup via Provider)
                    if (provider.isBannerVisible)
                      WilayahInfoBanner(
                        totalCount: provider.displayData.length,
                        onClose: () => provider.closeBanner(),
                      ),

                    const WilayahTableHeader(),

                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: provider.displayData.length,
                        itemBuilder: (context, index) {
                          final item = provider.displayData[index];

                          // --- LOGIC DETEKSI HEADER ---
                          bool isNewKabupaten = false;
                          bool isNewKecamatan = false;

                          if (index == 0) {
                            isNewKabupaten = true;
                            isNewKecamatan = true;
                          } else {
                            final prevItem = provider.displayData[index - 1];
                            if (prevItem.kabupaten != item.kabupaten) {
                              isNewKabupaten = true;
                              isNewKecamatan = true;
                            } else if (prevItem.kecamatan != item.kecamatan) {
                              isNewKecamatan = true;
                            }
                          }

                          // Ambil status expand dari Provider
                          final isKabOpen = provider.isKabupatenExpanded(
                            item.kabupaten,
                          );
                          final isKecOpen =
                              isKabOpen &&
                              provider.isKecamatanExpanded(item.kecamatan);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // HEADER KABUPATEN
                              if (isNewKabupaten)
                                WilayahKabupatenHeader(
                                  title: item.kabupaten,
                                  isExpanded: isKabOpen,
                                  onTap:
                                      () => provider.toggleKabupaten(
                                        item.kabupaten,
                                      ),
                                ),

                              // HEADER KECAMATAN
                              if (isNewKecamatan && isKabOpen)
                                WilayahKecamatanHeader(
                                  title: item.kecamatan,
                                  isExpanded: isKecOpen,
                                  onTap:
                                      () => provider.toggleKecamatan(
                                        item.kecamatan,
                                      ),
                                ),

                              // DATA ROW
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
