// import 'package:flutter/material.dart';

// // MODELS & REPO
// import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/models/lahan_history_model.dart';
// import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/repos/lahan_history_repos.dart';

// class LandHistoryProvider with ChangeNotifier {
//   final LandHistoryRepository _repo = LandHistoryRepository();

//   // --- STATE ---
//   LandHistorySummaryModel? _summaryData;
//   List<LandHistoryItemModel> _allData = []; // Data mentah dari API/Repo
//   List<LandHistoryItemModel> _displayData = []; // Data yang ditampilkan (hasil filter)
  
//   Map<String, List<LandHistoryItemModel>> _groupedData = {}; // Data Grouping untuk UI
  
//   bool _isLoading = false;
//   String? _errorMessage;

//   // --- GETTERS ---
//   LandHistorySummaryModel? get summaryData => _summaryData;
//   Map<String, List<LandHistoryItemModel>> get groupedData => _groupedData;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   bool get isEmpty => _displayData.isEmpty;

//   // --- ACTIONS ---

//   // 1. Fetch Data (Concurrent)
//   Future<void> fetchHistory() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       // Optimasi: Fetch Summary & List bersamaan
//       final results = await Future.wait([
//         _repo.getSummaryStats(),
//         _repo.getHistoryList(),
//       ]);

//       _summaryData = results[0] as LandHistorySummaryModel;
//       _allData = results[1] as List<LandHistoryItemModel>;
//       _displayData = List.from(_allData);

//       // Proses grouping awal
//       _groupData();
      
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       debugPrint("Error loading history: $e");
//       _errorMessage = e.toString();
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // 2. Search Logic
//   void search(String query) {
//     if (query.isEmpty) {
//       _displayData = List.from(_allData);
//     } else {
//       final lowerQuery = query.toLowerCase();
//       _displayData = _allData.where((item) {
//         return item.polisiPenggerak.toLowerCase().contains(lowerQuery) ||
//                item.penanggungJawab.toLowerCase().contains(lowerQuery) ||
//                item.regionGroup.toLowerCase().contains(lowerQuery);
//       }).toList();
//     }
//     // Update Grouping setelah filter
//     _groupData(); 
//     notifyListeners();
//   }

//   // 3. Filter Logic (Dari Dialog)
//   void applyFilter(String keyword, List<String> categories) {
//     if (keyword.isEmpty && categories.isEmpty) {
//       _displayData = List.from(_allData);
//     } else {
//        _displayData = _allData.where((item) {
//          bool matchKeyword = true;
//          if (keyword.isNotEmpty) {
//            matchKeyword = item.polisiPenggerak.contains(keyword);
//          }
//          return matchKeyword;
//        }).toList();
//     }
//     _groupData();
//     notifyListeners();
//   }

//   void resetFilter() {
//     _displayData = List.from(_allData);
//     _groupData();
//     notifyListeners();
//   }

//   // --- INTERNAL HELPERS ---

//   // Pure Function untuk grouping data berdasarkan Region
//   void _groupData() {
//     _groupedData = {};
//     for (var item in _displayData) {
//       _groupedData.putIfAbsent(item.regionGroup, () => []).add(item);
//     }
//   }
// }