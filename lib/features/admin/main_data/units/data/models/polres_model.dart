import 'wilayah_model.dart';

class PolresModel {
  final int id;
  final String namaPolres;
  final String kapolres;
  final String noTelp;
  final int wilayahId;
  final WilayahModel? wilayah; // Optional, jika Backend kirim preload

  PolresModel({
    required this.id,
    required this.namaPolres,
    required this.kapolres,
    required this.noTelp,
    required this.wilayahId,
    this.wilayah,
  });

  factory PolresModel.fromJson(Map<String, dynamic> json) {
    return PolresModel(
      id: json['id_polres'] ?? 0,
      namaPolres: json['nama_polres'] ?? '',
      kapolres: json['kapolres'] ?? '',
      noTelp: json['no_telp_polres'] ?? '',
      wilayahId: json['id_wilayah'] ?? 0,
      wilayah: json['wilayah'] != null ? WilayahModel.fromJson(json['wilayah']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_polres': id,
      'nama_polres': namaPolres,
      'kapolres': kapolres,
      'no_telp_polres': noTelp,
      'id_wilayah': wilayahId,
    };
  }
}