import 'package:KETAHANANPANGAN/features/admin/main_data/units/data/controllers/unit_controllers.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/data/models/unit_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/data/models/unit_region_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/presentation/widgets/unit_filter_dialog.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/presentation/widgets/unit_search_bar.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/presentation/widgets/unit_item_card.dart';

class UnitsPage extends ConsumerStatefulWidget {
  const UnitsPage({super.key});

  @override
  ConsumerState<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends ConsumerState<UnitsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _calculateTotalUnits(List<UnitRegionViewModel> list) {
    int total = 0;
    for (var region in list) {
      total += 1; // Hitung Polres
      total += region.polseks.length; // Hitung anak-anak Polseknya
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final unitState = ref.watch(unitControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
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
                    // Panggil fungsi search di Controller
                    ref.read(unitControllerProvider.notifier).search(val);
                  },
                  onFilterTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => UnitFilterDialog(
                            onApply: () {
                              Navigator.pop(context);
                            },
                            onReset: () {
                              Navigator.pop(context);
                            },
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
          // Kita tampilkan total unit hanya jika data sudah selesai loading
          if (unitState.hasValue)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Text(
                "DITEMUKAN ${_calculateTotalUnits(unitState.value!)} UNIT KESATUAN",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

          // ---------------------------------------
          // 3. BAGIAN LIST (AsyncValue Handling)
          // ---------------------------------------
          Expanded(
            child: unitState.when(
              // A. LOADING STATE
              loading: () => const Center(child: CircularProgressIndicator()),

              // B. ERROR STATE
              error:
                  (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Terjadi Kesalahan:\n$error",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed:
                              () =>
                                  ref
                                      .read(unitControllerProvider.notifier)
                                      .refresh(),
                          child: const Text("Coba Lagi"),
                        ),
                      ],
                    ),
                  ),

              // C. DATA LOADED STATE
              data: (unitList) {
                if (unitList.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh:
                      () => ref.read(unitControllerProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: unitList.length,
                    separatorBuilder:
                        (ctx, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final region = unitList[index];

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
                              // Panggil toggle di Controller (Index-based)
                              ref
                                  .read(unitControllerProvider.notifier)
                                  .toggleExpand(index);
                            },
                          ),

                          // B. Children (Polsek) - Hanya muncul jika Expanded
                          if (region.isExpanded)
                            Column(
                              children:
                                  region.polseks.map((polsek) {
                                    final childUnit = UnitModel(
                                      title: polsek.namaPolsek,
                                      subtitle: "Kapolsek: ${polsek.kapolsek}",
                                      count: "Kode: ${polsek.kode}",
                                      isPolres: false,
                                    );

                                    return UnitItemCard(
                                      unit: childUnit,
                                      isExpanded: false,
                                      // onExpandTap: null atau kosong karena anak tidak punya cucu
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
