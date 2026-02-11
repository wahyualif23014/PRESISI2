// import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/data/repos/commodity_item_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/data/models/commodity_category_model.dart';
// import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/data/repos/commodity_category_repository.dart';

// class CommodityCategoryProvider with ChangeNotifier {
//   // --- STATE ---
//   List<CommodityCategoryModel> _allData = [];
//   List<CommodityCategoryModel> _displayData = [];
//   bool _isLoading = false;
//   String? _errorMessage;

//   // --- GETTERS ---
//   List<CommodityCategoryModel> get displayData => _displayData;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;

//   // --- ACTIONS ---

//   // 1. Fetch Data
//   Future<void> fetchCategories() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final data = CommodityRepository.getCategoryData(); 
      
//       await Future.delayed(const Duration(seconds: 1));

//       _allData = data;
//       _displayData = List.from(data);
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = e.toString();
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // 2. Search
//   void search(String query) {
//     if (query.isEmpty) {
//       _displayData = List.from(_allData);
//     } else {
//       _displayData = _allData.where((item) {
//         return item.title.toLowerCase().contains(query.toLowerCase());
//       }).toList();
//     }
//     notifyListeners();
//   }

//   // 3. Add Data (Simulasi Local)
//   void addCategory(String title, String description) {
//     final newItem = CommodityCategoryModel(
//       title: title,
//       totalItems: 0, // Default 0
//       iconPath: 'assets/icons/default.png', // Icon default
//       description: description,
//       backgroundColor: const Color(0xFFE0F7FA), // Warna default
//     );

//     _allData.add(newItem);
//     search(""); // Reset search/refresh display
//     notifyListeners();
//   }

//   // 4. Edit Data (Simulasi Local)
//   void editCategory(CommodityCategoryModel oldItem, String newTitle, String newDesc) {
//     final index = _allData.indexOf(oldItem);
//     if (index != -1) {
//       // Kita buat object baru dengan data yang diupdate
//       final updatedItem = CommodityCategoryModel(
//         title: newTitle,
//         description: newDesc,
//         totalItems: oldItem.totalItems,
//         iconPath: oldItem.iconPath,
//         backgroundColor: oldItem.backgroundColor,
//       );
      
//       _allData[index] = updatedItem;
//       search(""); // Refresh list
//       notifyListeners();
//     }
//   }

//   // 5. Delete Data (Simulasi Local)
//   void deleteCategory(CommodityCategoryModel item) {
//     _allData.remove(item);
//     search("");
//     notifyListeners();
//   }

//   void refresh() {
//     fetchCategories();
//   }
// }

//iseh kurang komditidurung fiks ya