import 'polres_model.dart';
import 'wilayah_model.dart';

class PolsekModel {
  final int id;
  final String namaPolsek;
  final String kapolsek;
  final String noTelp;
  final String kode;
  final int polresId;
  final int wilayahId;
  final PolresModel? polres;   // Optional (Preload)
  final WilayahModel? wilayah; // Optional (Preload)

  PolsekModel({
    required this.id,
    required this.namaPolsek,
    required this.kapolsek,
    required this.noTelp,
    required this.kode,
    required this.polresId,
    required this.wilayahId,
    this.polres,
    this.wilayah,
  });

  factory PolsekModel.fromJson(Map<String, dynamic> json) {
    return PolsekModel(
      id: json['id_polsek'] ?? 0,
      namaPolsek: json['nama_polsek'] ?? '',
      kapolsek: json['kapolsek'] ?? '',
      noTelp: json['no_telp_polsek'] ?? '',
      kode: json['kode'] ?? '',
      polresId: json['id_polres'] ?? 0,
      wilayahId: json['id_wilayah'] ?? 0,
      polres: json['polres'] != null ? PolresModel.fromJson(json['polres']) : null,
      wilayah: json['wilayah'] != null ? WilayahModel.fromJson(json['wilayah']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_polsek': id,
      'nama_polsek': namaPolsek,
      'kapolsek': kapolsek,
      'no_telp_polsek': noTelp,
      'kode': kode,
      'id_polres': polresId,
      'id_wilayah': wilayahId,
    };
  }
}