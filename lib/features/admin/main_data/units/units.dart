import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Ganti Riverpod dengan Provider

// IMPORT PROVIDER BARU
import 'package:KETAHANANPANGAN/features/admin/main_data/units/providers/unit_provider.dart';

// IMPORT MODEL & WIDGET
import 'package:KETAHANANPANGAN/features/admin/main_data/units/data/models/unit_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/presentation/widgets/unit_filter_dialog.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/presentation/widgets/unit_search_bar.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/presentation/widgets/unit_item_card.dart';

class UnitsPage extends StatefulWidget {
  const UnitsPage({super.key});

  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnitProvider>().fetchUnits();
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
      backgroundColor: Colors.grey.shade100,
      // Gunakan Consumer untuk mendengarkan perubahan state
      body: Consumer<UnitProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // ---------------------------------------
              // 1. BAGIAN HEADER (Search & Filter)
              // ---------------------------------------
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    UnitSearchFilter(
                      controller: _searchController,
                      onChanged: (val) {
                        // Panggil fungsi search di Provider
                        provider.search(val);
                      },
                      onFilterTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => UnitFilterDialog(
                            onApply: () => Navigator.pop(context),
                            onReset: () => Navigator.pop(context),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ---------------------------------------
              // 2. BAGIAN INFO BANNER
              // ---------------------------------------
              // Tampilkan hanya jika tidak loading dan tidak error
              if (!provider.isLoading && provider.errorMessage == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Text(
                    // Ambil total calculation dari Getter Provider
                    "DITEMUKAN ${provider.totalUnits} UNIT KESATUAN",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),

              // ---------------------------------------
              // 3. BAGIAN LIST (Handling States)
              // ---------------------------------------
              Expanded(
                child: Builder(
                  builder: (context) {
                    // A. LOADING STATE
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // B. ERROR STATE
                    if (provider.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 40),
                            const SizedBox(height: 10),
                            Text(
                              "Terjadi Kesalahan:\n${provider.errorMessage}",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => provider.fetchUnits(),
                              child: const Text("Coba Lagi"),
                            ),
                          ],
                        ),
                      );
                    }

                    // C. EMPTY STATE
                    if (provider.units.isEmpty) {
                      return _buildEmptyState();
                    }

                    // D. DATA LIST
                    return RefreshIndicator(
                      onRefresh: () => provider.refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: provider.units.length,
                        separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final region = provider.units[index];

                          // Mapping Data Polres
                          final parentUnit = UnitModel(
                            title: region.polres.namaPolres,
                            subtitle: "Kapolres: ${region.polres.kapolres}",
                            count: "${region.polseks.length} Polsek",
                            isPolres: true,
                          );

                          return Column(
                            children: [
                              // A. Parent (Polres)
                              UnitItemCard(
                                unit: parentUnit,
                                isExpanded: region.isExpanded,
                                onExpandTap: () {
                                  // Panggil toggle di Provider
                                  provider.toggleExpand(index);
                                },
                              ),

                              // B. Children (Polsek) - Muncul jika Expanded
                              if (region.isExpanded)
                                Column(
                                  children: region.polseks.map((polsek) {
                                    final childUnit = UnitModel(
                                      title: polsek.namaPolsek,
                                      subtitle: "Kapolsek: ${polsek.kapolsek}",
                                      count: "Kode: ${polsek.kode}",
                                      isPolres: false,
                                    );

                                    return UnitItemCard(
                                      unit: childUnit,
                                      isExpanded: false,
                                    );
                                  }).toList(),
                                ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Data tidak ditemukan",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}