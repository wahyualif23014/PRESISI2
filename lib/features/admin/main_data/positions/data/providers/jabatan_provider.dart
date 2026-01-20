// // Lokasi: lib/features/admin/main_data/jabatan/controllers/jabatan_provider.dart

// import 'package:flutter/material.dart';
// import 'package:sdmapp/features/admin/main_data/positions/data/models/position_model.dart';
// import 'package:sdmapp/features/admin/main_data/positions/data/models/position_repository.dart';

// class JabatanProvider extends ChangeNotifier {
//   // 1. STATE VARIABLES
//   List<JabatanModel> _items = [];        // Master data
//   List<JabatanModel> _filteredItems = []; // Data yang tampil (hasil search)
//   String _searchQuery = '';

//   // Getter agar UI bisa mengakses data
//   List<JabatanModel> get items => _filteredItems;
  
//   // Getter untuk mengetahui berapa item yang dicentang (untuk tombol Delete massal)
//   int get selectedCount => _items.where((e) => e.isSelected).length;

//   // ---------------------------------------------------------------------------
//   // 2. INITIALIZATION (READ)
//   // ---------------------------------------------------------------------------
//   void loadData() {
//     // Mengambil data dummy dari Repository yang sudah kita buat
//     _items = JabatanRepository.getDummyData();
//     _filteredItems = List.from(_items); // Copy data ke filtered
//     notifyListeners();
//   }

//   // ---------------------------------------------------------------------------
//   // 3. SEARCH LOGIC
//   // ---------------------------------------------------------------------------
//   void search(String query) {
//     _searchQuery = query;
//     if (query.isEmpty) {
//       _filteredItems = List.from(_items);
//     } else {
//       _filteredItems = _items.where((item) {
//         final titleLower = item.namaJabatan.toLowerCase();
//         final nameLower = (item.namaPejabat ?? '').toLowerCase();
//         final searchLower = query.toLowerCase();

//         return titleLower.contains(searchLower) || nameLower.contains(searchLower);
//       }).toList();
//     }
//     notifyListeners();
//   }

//   // ---------------------------------------------------------------------------
//   // 4. CRUD OPERATIONS (Manipulasi Lokal)
//   // ---------------------------------------------------------------------------

//   // A. CREATE (Tambah Data Baru)
//   void addJabatan(JabatanModel newItem) {
//     _items.add(newItem);
//     _refreshFilter(); // Update tampilan
//   }

//   // B. UPDATE (Edit Data)
//   void updateJabatan(JabatanModel updatedItem) {
//     final index = _items.indexWhere((element) => element.id == updatedItem.id);
//     if (index != -1) {
//       _items[index] = updatedItem;
//       _refreshFilter();
//     }
//   }

//   // C. DELETE (Hapus Satu Data)
//   void deleteJabatan(String id) {
//     _items.removeWhere((element) => element.id == id);
//     _refreshFilter();
//   }

//   // D. BULK DELETE (Hapus yang dicentang)
//   // Sesuai tombol "Delete" merah di screenshot
//   void deleteSelectedItems() {
//     _items.removeWhere((element) => element.isSelected);
//     _refreshFilter();
//   }

//   // ---------------------------------------------------------------------------
//   // 5. SELECTION LOGIC (CHECKBOX)
//   // ---------------------------------------------------------------------------
  
//   // Toggle satu item (diklik checkbox-nya)
//   void toggleSelection(String id) {
//     final index = _items.indexWhere((e) => e.id == id);
//     if (index != -1) {
//       _items[index].isSelected = !_items[index].isSelected;
//       notifyListeners(); // Hanya notify, tidak perlu refresh filter
//     }
//   }

//   // Toggle Select All (Checkbox di header tabel)
//   void toggleSelectAll(bool? value) {
//     if (value == null) return;
//     for (var item in _items) {
//       item.isSelected = value;
//     }
//     notifyListeners();
//   }

//   // Helper Private: Refresh list tampilan sesuai search query saat ini
//   void _refreshFilter() {
//     search(_searchQuery); // Jalankan ulang logic search agar list ter-update
//   }
// }