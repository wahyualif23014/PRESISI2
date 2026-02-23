// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/providers/land_history_provider.dart';
// import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/models/lahan_history_model.dart';
// import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/presentation/widgets/search_kelola_lahan.dart';
// import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/presentation/widget/filter_riwayat.dart';
// import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/presentation/widget/history_list.dart';
// import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/presentation/widget/history_summary.dart';
// import 'package:KETAHANANPANGAN/features/operator/riwayat_lahan/providers/land_history_provider.dart';


// class RiwayatKelolaLahanPage extends StatefulWidget {
//   const RiwayatKelolaLahanPage({super.key});

//   @override
//   State<RiwayatKelolaLahanPage> createState() => _RiwayatKelolaLahanPageState();
// }

// class _RiwayatKelolaLahanPageState extends State<RiwayatKelolaLahanPage> {
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<LandHistoryProvider>().fetchHistory();
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _showFilterDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) {
//         return FilterriwayatDialog(
//           onApply: (keyword, selectedFilters) {
//             context.read<LandHistoryProvider>().applyFilter(
//               keyword,
//               selectedFilters,
//             );
//           },
//           onReset: () {
//             context.read<LandHistoryProvider>().resetFilter();
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SearchKelolaLahan(
//               controller: _searchController,
//               onChanged: (val) {
//                 context.read<LandHistoryProvider>().search(val);
//               },
//               onFilterTap: () => _showFilterDialog(context),
//             ),
//           ),
//           Expanded(
//             child: Consumer<LandHistoryProvider>(
//               builder: (context, provider, child) {
//                 if (provider.isLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (provider.errorMessage != null) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.error_outline,
//                           color: Colors.red,
//                           size: 40,
//                         ),
//                         const SizedBox(height: 10),
//                         Text("Error: ${provider.errorMessage}"),
//                         const SizedBox(height: 10),
//                         ElevatedButton(
//                           onPressed: () => provider.fetchHistory(),
//                           child: const Text("Coba Lagi"),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView(
//                   padding: const EdgeInsets.only(bottom: 80),
//                   children: [
//                     if (provider.summaryData != null)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: HistorySummary(data: provider.summaryData!),
//                       ),
//                     const SizedBox(height: 16),
//                     const _HistoryTableHeader(),
//                     if (provider.isEmpty)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 50),
//                         child: Center(child: Text("Tidak ada riwayat data")),
//                       )
//                     else
//                       ...provider.groupedData.entries.map((entry) {
//                         return HistoryRegionExpansionTile(
//                           title: entry.key,
//                           items: entry.value,
//                         );
//                       }),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HistoryTableHeader extends StatelessWidget {
//   const _HistoryTableHeader();

//   static const TextStyle _headerStyle = TextStyle(
//     fontSize: 9,
//     fontWeight: FontWeight.bold,
//     color: Colors.black87,
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.grey.shade200,
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//       child: const Row(
//         children: [
//           Expanded(
//             flex: 3,
//             child: Text("POLISI PENGGERAK", style: _headerStyle),
//           ),
//           Expanded(flex: 3, child: Text("PJ", style: _headerStyle)),
//           Expanded(
//             flex: 2,
//             child: Center(child: Text("LUAS (HA)", style: _headerStyle)),
//           ),
//           Expanded(
//             flex: 2,
//             child: Center(child: Text("VALIDASI", style: _headerStyle)),
//           ),
//           Expanded(
//             flex: 1,
//             child: Center(child: Text("AKSI", style: _headerStyle)),
//           ),
//         ],
//       ),
//     );
//   }
// }
