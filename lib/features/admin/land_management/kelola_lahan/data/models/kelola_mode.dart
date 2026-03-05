class LandManagementSummaryModel {
  final double totalPotensiLahan;
  final double totalTanamLahan;
  final double totalPanenLahanHa;
  final double totalPanenLahanTon;
  final double totalSerapanTon;

  LandManagementSummaryModel({
    required this.totalPotensiLahan,
    required this.totalTanamLahan,
    required this.totalPanenLahanHa,
    required this.totalPanenLahanTon,
    required this.totalSerapanTon,
  });

  factory LandManagementSummaryModel.fromJson(Map<String, dynamic> json) {
    return LandManagementSummaryModel(
      totalPotensiLahan: (json['total_potensi'] as num?)?.toDouble() ?? 0.0,
      totalTanamLahan: (json['total_tanam'] as num?)?.toDouble() ?? 0.0,
      totalPanenLahanHa: (json['total_panen_ha'] as num?)?.toDouble() ?? 0.0,
      totalPanenLahanTon: (json['total_panen_ton'] as num?)?.toDouble() ?? 0.0,
      totalSerapanTon: (json['total_serapan'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LandManagementItemModel {
  final String id;
  final String regionGroup;
  final String subRegionGroup;
  final String policeName;
  final String policePhone;
  final String picName;
  final String picPhone;
  final double landArea;
  final double luasTanam;
  final String estPanen;
  final double luasPanen;
  final double hasilPanen;
  final double serapan;
  final String status;
  final String statusColor;
  final String kategoriLahan;
  final String polresName;
  final String polsekName;
  final String jenisLahanName;
  final String keterangan;
  final String keteranganLain;
  final String jmlPoktan;
  final int jmlPetani;
  final String komoditiName;
  final String alamatLahan;
  final String wilayahLahan;
  final String idTanam;
  final String tglTanam;
  final double luasTanamDetail;
  final String jenisBibit;
  final double kebutuhanBibit;
  final String estAwalPanen;
  final String estAkhirPanen;
  final String dokumenPendukung;
  final String keteranganTanam;

  LandManagementItemModel({
    required this.id,
    required this.regionGroup,
    required this.subRegionGroup,
    required this.policeName,
    required this.policePhone,
    required this.picName,
    required this.picPhone,
    required this.landArea,
    required this.luasTanam,
    required this.estPanen,
    required this.luasPanen,
    required this.hasilPanen,
    required this.serapan,
    required this.status,
    required this.statusColor,
    this.kategoriLahan = '-',
    required this.polresName,
    required this.polsekName,
    required this.jenisLahanName,
    required this.keterangan,
    required this.keteranganLain,
    required this.jmlPoktan,
    required this.jmlPetani,
    required this.komoditiName,
    required this.alamatLahan,
    required this.wilayahLahan,
    required this.idTanam,
    required this.tglTanam,
    required this.luasTanamDetail,
    required this.jenisBibit,
    required this.kebutuhanBibit,
    required this.estAwalPanen,
    required this.estAkhirPanen,
    required this.dokumenPendukung,
    required this.keteranganTanam,
  });

  factory LandManagementItemModel.fromJson(Map<String, dynamic> json) {
    return LandManagementItemModel(
      id: json['id']?.toString() ?? '',
      regionGroup: json['region_group'] ?? '-',
      subRegionGroup: json['sub_region_group'] ?? '-',
      policeName: json['police_name'] ?? '-',
      policePhone: json['police_phone'] ?? '-',
      picName: json['pic_name'] ?? '-',
      picPhone: json['pic_phone'] ?? '-',
      landArea: (json['land_area'] as num?)?.toDouble() ?? 0.0,
      luasTanam: (json['luas_tanam'] as num?)?.toDouble() ?? 0.0,
      estPanen: json['est_panen'] ?? '-',
      luasPanen: (json['luas_panen'] as num?)?.toDouble() ?? 0.0,
      hasilPanen: (json['berat_panen'] as num?)?.toDouble() ?? 0.0,
      serapan: (json['serapan'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
      statusColor: json['status_color'] ?? '#FF9800',
      polresName: json['polres_name'] ?? '-',
      polsekName: json['polsek_name'] ?? '-',
      jenisLahanName: json['jenis_lahan_name'] ?? '-',
      keterangan: json['keterangan'] ?? '-',
      keteranganLain: json['keterangan_lain'] ?? '-',
      jmlPoktan: json['jml_poktan']?.toString() ?? '0',
      jmlPetani: (json['jml_petani'] as num?)?.toInt() ?? 0,
      komoditiName: json['komoditi_name'] ?? '-',
      alamatLahan: json['alamat_lahan'] ?? '-',
      wilayahLahan: json['wilayah_lahan'] ?? '-',
      idTanam: json['id_tanam']?.toString() ?? '',
      tglTanam: json['tgl_tanam'] ?? '',
      luasTanamDetail: (json['luas_tanam_detail'] as num?)?.toDouble() ?? 0.0,
      jenisBibit: json['jenis_bibit'] ?? '',
      kebutuhanBibit: (json['kebutuhan_bibit'] as num?)?.toDouble() ?? 0.0,
      estAwalPanen: json['est_awal_panen'] ?? '',
      estAkhirPanen: json['est_akhir_panen'] ?? '',
      dokumenPendukung: json['dokumen_pendukung'] ?? '',
      keteranganTanam: json['keterangan_tanam'] ?? '',
    );
  }
}
