import 'dart:convert';
import 'package:flutter/foundation.dart'; // Wajib ada untuk debugPrint
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kelola_mode.dart';

class LandManagementRepository {
  // Pastikan IP ini benar (IP Laptop/Server Go kamu)
  final String baseUrl = "http://192.168.100.195:8080/api/kelola-lahan";

  // Helper: Ambil Token
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') ?? '';
  }

  // 1. GET FILTER OPTIONS (Untuk Dropdown di Dialog)
  Future<Map<String, List<String>>> getFilterOptions({
    String? polres,
    String? polsek,
  }) async {
    // Bangun URL dengan query parameter
    String url = '$baseUrl/filter-options?';
    if (polres != null && polres.isNotEmpty) url += 'polres=$polres&';
    if (polsek != null && polsek.isNotEmpty) url += 'polsek=$polsek';

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'polres': List<String>.from(data['polres'] ?? []),
          'polsek': List<String>.from(data['polsek'] ?? []),
          'jenis_lahan': List<String>.from(data['jenis_lahan'] ?? []),
          'komoditas': List<String>.from(data['komoditas'] ?? []),
        };
      }
      return {};
    } catch (e) {
      debugPrint("Error fetching filter options: $e");
      return {};
    }
  }

  // 2. GET SUMMARY
  Future<LandManagementSummaryModel> getSummaryStats() async {
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/summary'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LandManagementSummaryModel.fromJson(data);
      } else {
        return LandManagementSummaryModel(
          totalPotensiLahan: 0,
          totalTanamLahan: 0,
          totalPanenLahanHa: 0,
          totalPanenLahanTon: 0,
          totalSerapanTon: 0,
        );
      }
    } catch (e) {
      return LandManagementSummaryModel(
        totalPotensiLahan: 0,
        totalTanamLahan: 0,
        totalPanenLahanHa: 0,
        totalPanenLahanTon: 0,
        totalSerapanTon: 0,
      );
    }
  }

  // 3. GET LIST (Dengan Search & Filter Lengkap)
  Future<List<LandManagementItemModel>> getLandManagementList({
    String keyword = "",
    Map<String, String>? filters, // Parameter Tambahan untuk Filter
  }) async {
    final token = await _getToken();

    // Susun URL Dasar
    String url = '$baseUrl/list?search=$keyword';

    // Tambahkan Parameter Filter ke URL jika ada
    if (filters != null) {
      if (filters['polres'] != null && filters['polres']!.isNotEmpty) {
        url += '&polres=${filters['polres']}';
      }
      if (filters['polsek'] != null && filters['polsek']!.isNotEmpty) {
        url += '&polsek=${filters['polsek']}';
      }
      if (filters['jenis_lahan'] != null &&
          filters['jenis_lahan']!.isNotEmpty) {
        url += '&jenis_lahan=${filters['jenis_lahan']}';
      }
      if (filters['komoditas'] != null && filters['komoditas']!.isNotEmpty) {
        url += '&komoditas=${filters['komoditas']}';
      }
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => LandManagementItemModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error repo list: $e");
      return [];
    }
  }
}
