import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/commodity_category_model.dart';
import '../models/commodity_model.dart';

// Class Wrapper untuk hasil fetch (List + Total)
class CategoryFetchResult {
  final List<CommodityCategoryModel> categories;
  final int totalItems;

  CategoryFetchResult({required this.categories, required this.totalItems});
}

class CommodityService {
  // Pastikan IP ini sesuai dengan IP Laptop/Komputer kamu saat ini
  static const String baseUrl = "http://10.16.7.4:8080/api";

  // PERBAIKAN: Menggunakan key 'jwt_token' agar sinkron dengan AuthProvider
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') ?? '';
  }

  // 1. Fetch Categories & Total Items (ENDPOINT UTAMA)
  Future<CategoryFetchResult> fetchCategoriesData() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];

        // Ambil 'total_items' dari JSON backend
        final int tItems = body['total_items'] ?? 0;

        return CategoryFetchResult(
          categories:
              data.map((e) => CommodityCategoryModel.fromJson(e)).toList(),
          totalItems: tItems,
        );
      }
      return CategoryFetchResult(categories: [], totalItems: 0);
    } catch (e) {
      print("Error: $e");
      return CategoryFetchResult(categories: [], totalItems: 0);
    }
  }

  // 2. Add Commodity (Tambah Data Baru)
  Future<bool> addCommodity(String categoryId, String name) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': name, 'categoryId': categoryId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 3. Delete Category (Hapus Massal Kategori)
  Future<bool> deleteCategory(String kindName) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories/delete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'kindName': kindName}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 4. Fetch Detail Items (Untuk Halaman Detail)
  Future<List<CommodityModel>> fetchCommoditiesByKind(String kind) async {
    final token = await _getToken();
    try {
      final uri = Uri.parse(
        '$baseUrl/commodities',
      ).replace(queryParameters: {'kind': kind});
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((e) => CommodityModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 5. Update Commodity (Edit Nama Tanaman)
  Future<bool> updateCommodity(String id, String newName) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/commodity/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'id': id, 'name': newName}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 6. Delete Single Item (Hapus 1 Tanaman)
  Future<bool> deleteCommodityItem(String id) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/commodity/delete-item'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'id': id}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
