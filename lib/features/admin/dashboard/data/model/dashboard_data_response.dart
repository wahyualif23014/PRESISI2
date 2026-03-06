import 'summary_item_model.dart';
import 'ringkasan_area_model.dart';
import 'harvest_model.dart';
import 'kwartal_item_model.dart';
import 'distribution_model.dart';
import 'resapan_model.dart';

class DashboardDataResponse {
  final List<SummaryItemModel> summaryData;
  final List<RingkasanAreaModel> lahanData;
  final HarvestModel? harvestData;
  final List<QuarterlyItem> quarterlyData;
  final List<DistributionModel> distributionData;
  final ResapanModel? resapanData;
  final String activeFilterLabel;

  // ✅ BARU: map potensi dari backend
  final MapPotensiModel? mapPotensi;

  DashboardDataResponse({
    required this.summaryData,
    required this.lahanData,
    this.harvestData,
    required this.quarterlyData,
    required this.distributionData,
    this.resapanData,
    required this.activeFilterLabel,
    this.mapPotensi,
  });

  factory DashboardDataResponse.fromJson(Map<String, dynamic> json) {
    return DashboardDataResponse(
      summaryData: (json['summary_data'] as List? ?? [])
          .map((x) => SummaryItemModel.fromJson(x))
          .toList(),
      lahanData: (json['lahan_data'] as List? ?? [])
          .map((x) => RingkasanAreaModel.fromJson(x))
          .toList(),
      harvestData: json['harvest_data'] != null
          ? HarvestModel.fromJson(json['harvest_data'])
          : null,
      quarterlyData: (json['quarterly_data'] as List? ?? [])
          .map((x) => QuarterlyItem.fromJson(x))
          .toList(),
      distributionData: (json['distribution_data'] as List? ?? [])
          .map((x) => DistributionModel.fromJson(x))
          .toList(),
      resapanData: json['resapan_data'] != null
          ? ResapanModel.fromJson(json['resapan_data'])
          : null,
      activeFilterLabel: json['active_filter_label'] ?? "",
      mapPotensi: json['map_potensi'] != null
          ? MapPotensiModel.fromJson(
              Map<String, dynamic>.from(json['map_potensi']),
            )
          : null,
    );
  }
}

class MapPotensiModel {
  final int totalPoints;
  final List<MapPotensiItem> points;

  MapPotensiModel({
    required this.totalPoints,
    required this.points,
  });

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