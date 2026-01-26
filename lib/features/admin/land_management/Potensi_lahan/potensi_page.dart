import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/data/model/land_potential_model.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/data/repos/land_potential_repository.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/presentation/widget/add_land_data_page.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/presentation/widget/land_filter_dialog.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/presentation/widget/land_potential_group.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/presentation/widget/land_potential_toolbar.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/presentation/widget/land_summary_widget.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/presentation/widget/no_land_potential_widget.dart';

// edit, delete , reseoucrce belum
class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _CropsPageState();
}

class _CropsPageState extends State<OverviewPage> {
  final LandPotentialRepository _repo = LandPotentialRepository();

  List<LandPotentialModel> _dataList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _repo.getLandPotentials();
      if (mounted) {
        setState(() {
          _dataList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<LandPotentialModel>> groupedByKabupaten = {};
    for (var item in _dataList) {
      if (!groupedByKabupaten.containsKey(item.kabupaten)) {
        groupedByKabupaten[item.kabupaten] = [];
      }
      groupedByKabupaten[item.kabupaten]!.add(item);
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          LandPotentialToolbar(
            onSearchChanged: (query) {
              print("Mencari: $query");
            },
            onFilterTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const LandFilterDialog();
                },
              );
            },
            // DISINI PERUBAHANNYA:
            onAddTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddLandDataPage(),
                ),
              );
            },
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                      padding: const EdgeInsets.only(
                        bottom: 100,
                      ), // Padding untuk BottomNav
                      children: [
                        const LandSummaryWidget(),
                        const NoLandPotentialWidget(),
                        _buildHeaderPembatas("Daftar Potensi Lahan"),
                        if (_dataList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Center(
                              child: Text(
                                "Belum ada data potensi lahan",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ...groupedByKabupaten.entries.map((entry) {
                            return KabupatenExpansionTile(
                              kabupatenName: entry.key,
                              itemsInKabupaten: entry.value,
                            );
                          }),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}

Widget _buildHeaderPembatas(String title) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    padding: const EdgeInsets.only(left: 12.0),
    decoration: const BoxDecoration(
      border: Border(
        left: BorderSide(
          color: Colors.black, // Warna garis hitam
          width: 4.0, // Ketebalan garis
        ),
      ),
    ),

    // Teks Judulnya
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );
}
