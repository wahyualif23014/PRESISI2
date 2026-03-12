import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/commodity_category_model.dart';
import '../models/commodity_model.dart';

class CategoryFetchResult {
  final List<CommodityCategoryModel> categories;
  final int totalItems;

  CategoryFetchResult({required this.categories, required this.totalItems});
}

class CommodityService {
  static const String baseUrl = "http://192.168.100.195:8080/api/admin";
  final _storage = const FlutterSecureStorage();

  Future<String> _getToken() async {
    String? token = await _storage.read(key: 'jwt_token');
    return token ?? '';
  }

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
        final int tItems = body['total_items'] ?? 0;

        return CategoryFetchResult(
          categories:
              data.map((e) => CommodityCategoryModel.fromJson(e)).toList(),
          totalItems: tItems,
        );
      }
      return CategoryFetchResult(categories: [], totalItems: 0);
    } catch (e) {
      print("Error Fetch Categories: $e");
      return CategoryFetchResult(categories: [], totalItems: 0);
    }
  }

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
      print("Error Fetch Detail: $e");
      return [];
    }
  }

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
