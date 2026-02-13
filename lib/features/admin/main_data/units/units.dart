import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/providers/unit_provider.dart';
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
    // Memanggil data dari Backend saat halaman pertama kali dibuka
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
    final provider = context.watch<UnitProvider>();

    // Warna untuk garis penghubung (Jaring)
    final connectionColor = Colors.grey.shade300;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF3F4F6),
      body: RefreshIndicator(
        onRefresh: () => provider.refresh(),
        color: const Color(0xFF1E40AF),

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UnitSearchFilter(
                    controller: _searchController,
                    onChanged: (value) => provider.search(value),
                    onFilterTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => UnitFilterDialog(
                              initialPolres: provider.showPolres,
                              initialPolsek: provider.showPolsek,
                              initialWilayah: provider.selectedWilayah,

                              availableWilayahs: provider.uniqueWilayahList,

                              // Handle Apply
                              onApply: (isPolres, isPolsek, wilayah, query) {
                                if (query.isNotEmpty) {
                                  _searchController.text = query;
                                }
                                provider.applyFilter(
                                  isPolres,
                                  isPolsek,
                                  wilayah,
                                  _searchController.text,
                                );
                              },

                              // Handle Reset
                              onReset: () {
                                _searchController.clear();
                                provider.resetFilter();
                              },
                            ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child:
                  provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.errorMessage != null
                      ? Center(
                        child: Text(provider.errorMessage!),
                      ) // Tampilkan Error
                      : provider.units.isEmpty
                      ? _buildEmptyState() // Tampilkan jika data kosong
                      : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: provider.units.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final region = provider.units[index];

                          // A. MODEL UNTUK POLRES (PARENT)
                          final parentUnit = UnitModel(
                            title: region.polres.namaPolres,
                            subtitle: "Ka: ${region.polres.kapolres}",
                            // Mengambil nama wilayah (Contoh: WILAYAH GRESIK)
                            count:
                                "WILAYAH ${region.polres.wilayah?.kabupaten ?? '-'}",
                            isPolres: true,
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. KARTU UTAMA (POLRES)
                              UnitItemCard(
                                unit: parentUnit,
                                isExpanded: region.isExpanded,
                                onExpandTap: () => provider.toggleExpand(index),
                              ),

                              if (region.isExpanded)
                                Container(
                                  // Membuat Indentasi (Menjorok ke dalam)
                                  margin: const EdgeInsets.only(left: 28.0),
                                  // Membuat Garis Vertikal (Tiang Jaring)
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: connectionColor,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children:
                                        region.polseks.map((polsek) {
                                          // B. MODEL UNTUK POLSEK (CHILD)
                                          final childUnit = UnitModel(
                                            title: polsek.namaPolsek,
                                            subtitle:
                                                "Ka: ${polsek.kapolsek}\nHP: ${polsek.noTelp}",
                                            count: "KODE: ${polsek.kode}",
                                            isPolres: false,
                                          );

                                          // Row untuk Garis Horizontal + Kartu
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 12.0,
                                            ),
                                            child: Row(
                                              children: [
                                                // Garis Horizontal Kecil (Penghubung)
                                                Container(
                                                  width: 16.0,
                                                  height: 2.0,
                                                  color: connectionColor,
                                                ),
                                                // Kartu Polsek (Expanded agar teks panjang aman)
                                                Expanded(
                                                  child: UnitItemCard(
                                                    unit: childUnit,
                                                    isExpanded: false,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
            ),
          ],
        ),
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
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
