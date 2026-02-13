class NoLandPotentialModel {
  final int totalEmptyPolres;
  final int emptyPolsek;
  final int emptyKabKota;
  final int emptyKecamatan;
  final int emptyKelDesa;

  NoLandPotentialModel({
    required this.totalEmptyPolres,
    required this.emptyPolsek,
    required this.emptyKabKota,
    required this.emptyKecamatan,
    required this.emptyKelDesa,
  });

  factory NoLandPotentialModel.fromJson(Map<String, dynamic> json) {
    // FIX: Mengambil data dari object 'details', bukan list
    final details = json['details'] as Map<String, dynamic>? ?? {};

    return NoLandPotentialModel(
      totalEmptyPolres: (json['total_empty_polres'] ?? 0).toInt(),
      emptyPolsek: (details['polsek'] ?? 0).toInt(),
      emptyKabKota: (details['kab_kota'] ?? 0).toInt(),
      emptyKecamatan: (details['kecamatan'] ?? 0).toInt(),
      emptyKelDesa: (details['kel_desa'] ?? 0).toInt(),
    );
  }
}
