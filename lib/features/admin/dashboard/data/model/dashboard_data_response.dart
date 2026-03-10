import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/panen_status_item.dart';

import 'summary_item_model.dart';
import 'ringkasan_area_model.dart';
import 'harvest_model.dart';
import 'kwartal_item_model.dart';
import 'resapan_model.dart';
import 'wilayah_distribution_model.dart';

class DashboardDataResponse {
  final List<SummaryItemModel> summaryData;
  final List<RingkasanAreaModel> lahanData;
  final HarvestModel? harvestData;
  final List<QuarterlyItem> quarterlyData;
  final ResapanModel? resapanData;
  final String activeFilterLabel;
  final MapPotensiModel? mapPotensi;
  final List<PanenStatusItem> panenStatus;

  // distribution chart
  final List<WilayahDistributionModel> wilayahDistribution;

  DashboardDataResponse({
    required this.summaryData,
    required this.lahanData,
    this.harvestData,
    required this.quarterlyData,
    this.resapanData,
    required this.activeFilterLabel,
    this.mapPotensi,
    required this.panenStatus,
    required this.wilayahDistribution,
  });

  factory DashboardDataResponse.fromJson(Map<String, dynamic> json) {
    return DashboardDataResponse(
      summaryData: (json['summary_data'] as List<dynamic>? ?? [])
          .map((e) => SummaryItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      lahanData: (json['lahan_data'] as List<dynamic>? ?? [])
          .map((e) => RingkasanAreaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      harvestData: json['harvest_data'] != null
          ? HarvestModel.fromJson(
              Map<String, dynamic>.from(json['harvest_data']))
          : null,

      quarterlyData: (json['quarterly_data'] as List<dynamic>? ?? [])
          .map((e) => QuarterlyItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      resapanData: json['resapan_data'] != null
          ? ResapanModel.fromJson(Map<String, dynamic>.from(json['resapan_data']))
          : null,

      activeFilterLabel: (json['active_filter_label'] ?? "").toString(),

      mapPotensi: json['map_potensi'] != null
          ? MapPotensiModel.fromJson(Map<String, dynamic>.from(json['map_potensi']))
          : null,

      panenStatus: (json['panen_status'] as List<dynamic>? ?? [])
          .map((e) => PanenStatusItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      wilayahDistribution: (json['wilayah_distribution'] as List<dynamic>? ?? [])
          .map((e) => WilayahDistributionModel.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(),
    );
  }
}
class MapPotensiModel {
  final int totalPoints;
  final List<MapPotensiItem> points;

  MapPotensiModel({required this.totalPoints, required this.points});

  factory MapPotensiModel.fromJson(Map<String, dynamic> json) {
    return MapPotensiModel(
      totalPoints: (json['total_points'] ?? 0) is int
          ? (json['total_points'] ?? 0)
          : int.tryParse(json['total_points'].toString()) ?? 0,
      points: (json['points'] as List? ?? [])
          .map((e) => MapPotensiItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class MapPotensiItem {
  final String idLahan;
  final double lat;
  final double lng;
  final double luasLahan;
  final String statusLahan;
  final String jenisLahan;

  final String? idKomoditi;
  final String? namaKomoditi;
  final String? jenisKomoditi;

  final String? kodeWilayah;
  final String? namaWilayah;

  MapPotensiItem({
    required this.idLahan,
    required this.lat,
    required this.lng,
    required this.luasLahan,
    required this.statusLahan,
    required this.jenisLahan,
    this.idKomoditi,
    this.namaKomoditi,
    this.jenisKomoditi,
    this.kodeWilayah,
    this.namaWilayah,
  });

  factory MapPotensiItem.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return MapPotensiItem(
      idLahan: (json['id_lahan'] ?? '').toString(),
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
      luasLahan: _toDouble(json['luas_lahan']),
      statusLahan: (json['status_lahan'] ?? '').toString(),
      jenisLahan: (json['jenis_lahan'] ?? '').toString(),
      idKomoditi: json['id_komoditi']?.toString(),
      namaKomoditi: json['nama_komoditi']?.toString(),
      jenisKomoditi: json['jenis_komoditi']?.toString(),
      kodeWilayah: json['kode_wilayah']?.toString(),
      namaWilayah: json['nama_wilayah']?.toString(),
    );
  }
}