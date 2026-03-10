import 'dart:convert';
import 'dart:io';

import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/wilayah_distribution_model.dart'
    show WilayahDistributionModel;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/resapan_model.dart'
    show ResapanModel;

import '../model/dashboard_data_response.dart';

class KomoditiOption {
  final String id;
  final String label;

  KomoditiOption({required this.id, required this.label});

  factory KomoditiOption.fromJson(Map<String, dynamic> json) {
    return KomoditiOption(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
    );
  }
}

class DashboardService {
  final String apiBaseUrl = "http://10.16.14.46:8080/api";

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final http.Client _client = http.Client();

  static final DashboardService _instance = DashboardService._internal();

  factory DashboardService() => _instance;

  DashboardService._internal();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt_token') ?? '';

    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      if (token.isNotEmpty) HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  Uri _buildUri(String path, Map<String, String> query) {
    final base = Uri.parse(apiBaseUrl);

    return base.replace(
      path:
          (base.path.endsWith('/')
              ? base.path.substring(0, base.path.length - 1)
              : base.path) +
          path,
      queryParameters: query.isEmpty ? null : query,
    );
  }

  Map<String, String> _cleanParams(Map<String, String?> params) {
    final out = <String, String>{};

    params.forEach((k, v) {
      if (v == null) return;

      final val = v.trim();
      if (val.isEmpty) return;

      out[k] = val;
    });

    return out;
  }

  // =====================================================
  // DASHBOARD DATA
  // GET /api/dashboard
  // =====================================================

  Future<DashboardDataResponse?> getDashboardData({
    String? resor,
    String? sektor,
    String? idJenisLahan,
    String? jenisKomoditi,
    String? idKomoditi,
    String? tglMulai,
    String? tglSelesai,
  }) async {
    try {
      final queryParams = _cleanParams({
        'resor': resor,
        'sektor': sektor,
        'id_jenis_lahan': idJenisLahan,
        'jenis_komoditi': jenisKomoditi,
        'id_komoditi': idKomoditi,
        'tanggal_mulai': tglMulai,
        'tanggal_selesai': tglSelesai,
      });

      final uri = _buildUri('/dashboard', queryParams);

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        if (body['status'] == 'success' && body['data'] != null) {
          return DashboardDataResponse.fromJson(
            Map<String, dynamic>.from(body['data']),
          );
        }
      }

      return null;
    } catch (e) {
      debugPrint("Exception Dashboard Service: $e");
      rethrow;
    }
  }

  // =====================================================
  // MAP POTENSI
  // GET /api/dashboard/map-potensi
  // =====================================================

  Future<MapPotensiModel?> getMapPotensi({
    String? resor,
    String? sektor,
    String? idJenisLahan,
    String? jenisKomoditi,
    String? idKomoditi,
  }) async {
    try {
      final queryParams = _cleanParams({
        'resor': resor,
        'sektor': sektor,
        'id_jenis_lahan': idJenisLahan,
        'jenis_komoditi': jenisKomoditi,
        'id_komoditi': idKomoditi,
      });

      final uri = _buildUri('/dashboard/map-potensi', queryParams);

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        if (body['status'] == 'success' && body['data'] != null) {
          return MapPotensiModel.fromJson(
            Map<String, dynamic>.from(body['data']),
          );
        }
      }

      return null;
    } catch (e) {
      debugPrint("Exception getMapPotensi: $e");
      rethrow;
    }
  }

  // =====================================================
  // FILTER JENIS KOMODITI
  // GET /api/dashboard/filters/jenis-komoditi
  // =====================================================

  Future<List<String>> getJenisKomoditi() async {
    try {
      final uri = _buildUri('/dashboard/filters/jenis-komoditi', {});

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        if (body['status'] == 'success' && body['data'] is List) {
          final list = (body['data'] as List).map((e) => e.toString()).toList();

          return list.where((e) => e.trim().isNotEmpty).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("Exception getJenisKomoditi: $e");
      rethrow;
    }
  }
  // =====================================================
  // WILAYAH DISTRIBUTION
  // GET /api/dashboard/wilayah-distribution
  // =====================================================

  Future<List<WilayahDistributionModel>> getWilayahDistribution({
    String? resor,
    String? sektor,
    String? idJenisLahan,
    String? jenisKomoditi,
    String? idKomoditi,
  }) async {
    try {
      final queryParams = _cleanParams({
        'resor': resor,
        'sektor': sektor,
        'id_jenis_lahan': idJenisLahan,
        'jenis_komoditi': jenisKomoditi,
        'id_komoditi': idKomoditi,
      });

      final uri = _buildUri('/dashboard/wilayah-distribution', queryParams);

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        if (body['status'] == 'success' && body['data'] is List) {
          return (body['data'] as List)
              .whereType<Map>()
              .map(
                (e) => WilayahDistributionModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("Exception getWilayahDistribution: $e");
      rethrow;
    }
  }

  // =====================================================
  // KOMODITI BY JENIS
  // GET /api/dashboard/filters/komoditi
  // =====================================================

  Future<List<KomoditiOption>> getKomoditiByJenis(String jenisKomoditi) async {
    try {
      final uri = _buildUri(
        '/dashboard/filters/komoditi',
        _cleanParams({'jenis_komoditi': jenisKomoditi}),
      );

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        if (body['status'] == 'success' && body['data'] is List) {
          return (body['data'] as List)
              .whereType<Map>()
              .map((e) => KomoditiOption.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint("Exception getKomoditiByJenis: $e");
      rethrow;
    }
  }

  // =====================================================
  // RESAPAN SUMMARY
  // GET /api/dashboard/resapan

  // =====================================================

  Future<ResapanModel?> getResapanSummary({String? idKomoditi}) async {
    try {
      final queryParams = _cleanParams({'id_komoditi': idKomoditi});

      final uri = _buildUri('/dashboard/resapan', queryParams);

      final response = await _client
          .get(uri, headers: await _getHeaders())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        if (body['status'] == 'success' && body['data'] != null) {
          return ResapanModel.fromJson(Map<String, dynamic>.from(body['data']));
        }
      }

      return null;
    } catch (e) {
      debugPrint("Exception getResapanSummary: $e");
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
