import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/data/models/commodity_category_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/data/models/commodity_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/data/services/commodity_service.dart';
import 'package:flutter/material.dart';


class CommodityProvider with ChangeNotifier {
  final CommodityService _service = CommodityService();

  // State Variables
  List<CommodityCategoryModel> _categories = [];
  List<CommodityModel> _items = [];
  int _totalItemsCount = 0;
  bool _isLoading = false;

  // Getters
  List<CommodityCategoryModel> get categories => _categories;
  List<CommodityModel> get items => _items;
  int get totalItemsCount => _totalItemsCount;
  bool get isLoading => _isLoading;

  // 1. Ambil Semua Kategori (Halaman Utama)
  Future<void> fetchAllCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _service.fetchCategoriesData();
      _categories = result.categories;
      _totalItemsCount = result.totalItems;
    } catch (e) {
      debugPrint("Error Provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Ambil Detail Tanaman (Halaman Detail)
  Future<void> fetchItemsByKind(String kindName) async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _service.fetchCommoditiesByKind(kindName);
    } catch (e) {
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Tambah/Simpan Komoditas
  Future<bool> addCommodity(String category, String name) async {
    final success = await _service.addCommodity(category, name);
    if (success) await fetchAllCategories();
    return success;
  }

  // 4. Update Tanaman
  Future<bool> updateItem(String kindName, String id, String newName) async {
    final success = await _service.updateCommodity(id, newName);
    if (success) await fetchItemsByKind(kindName);
    return success;
  }

  // 5. Hapus Satu Tanaman
  Future<bool> deleteItem(String kindName, String id) async {
    final success = await _service.deleteCommodityItem(id);
    if (success) {
      await fetchItemsByKind(kindName);
      await fetchAllCategories(); // Update count di banner
    }
    return success;
  }

  // 6. Hapus Kategori Massal
  Future<bool> deleteCategories(Set<String> titles) async {
    bool allSuccess = true;
    for (var title in titles) {
      final success = await _service.deleteCategory(title);
      if (!success) allSuccess = false;
    }
    await fetchAllCategories();
    return allSuccess;
  }
}