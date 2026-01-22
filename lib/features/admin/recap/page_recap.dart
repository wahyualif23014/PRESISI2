import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/recap/data/model/recap_model.dart';
import 'package:sdmapp/features/admin/recap/data/repo/recap_repo.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_header_section.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_table_header.dart';
// Import Widget Group Baru
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_group_section.dart'; 

class PageRecap extends StatefulWidget {
  const PageRecap({Key? key}) : super(key: key);

  @override
  State<PageRecap> createState() => _PageRecapState();
}

class _PageRecapState extends State<PageRecap> {
  final RecapRepo _repo = RecapRepo();
  late Future<List<RecapModel>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _repo.getRecapData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 1. SEARCH, FILTER, PRINT SECTION
          RecapHeaderSection(
            onSearchChanged: (val) => print("Search: $val"),
            onFilterTap: () => print("Filter Tapped"),
            onPrintTap: () => print("Print Tapped"),
          ),

          const SizedBox(height: 16),

          const RecapTableHeader(),

          Expanded(
            child: FutureBuilder<List<RecapModel>>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Data Tidak Ditemukan"));
                }

                final rawData = snapshot.data!;
                

                final List<Widget> groupedWidgets = [];
                
                RecapModel? currentHeader;
                List<RecapModel> currentChildren = [];

                for (var item in rawData) {
                  if (item.isHeader) {
                    if (currentHeader != null) {
                      groupedWidgets.add(RecapGroupSection(
                        header: currentHeader, 
                        children: List.from(currentChildren), // Copy list
                      ));
                    }
                    currentHeader = item;
                    currentChildren = [];
                  } else {
                    // Jika item biasa, masukkan ke list anak
                    currentChildren.add(item);
                  }
                }
                
                if (currentHeader != null) {
                  groupedWidgets.add(RecapGroupSection(
                    header: currentHeader, 
                    children: currentChildren,
                  ));
                }
                // ----------------------------------

                return ListView(
                  padding: EdgeInsets.zero,
                  children: groupedWidgets,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}