class LandPotentialModel {
  final String id;

  // Wilayah (Langsung dari DB)
  final String kabupaten;
  final String kecamatan;
  final String desa;

  // Data Lainnya
  final String resor;
  final String sektor;
  final String jenisLahan;
  final double luasLahan;
  final String alamatLahan;
  final String statusValidasi;
  final String policeName;
  final String policePhone;
  final String picName;
  final String picPhone;
  final String keterangan;
  final int jumlahPoktan;
  final int jumlahPetani;
  final String komoditi;
  final String keteranganLain;
  final String fotoLahan;
  final String tglProses;
  final String diprosesOleh;
  final String divalidasiOleh;
  final String tglValidasi;

  LandPotentialModel({
    required this.id,
    required this.kabupaten,
    required this.kecamatan,
    required this.desa,
    required this.resor,
    required this.sektor,
    required this.jenisLahan,
    required this.luasLahan,
    required this.alamatLahan,
    required this.statusValidasi,
    required this.policeName,
    required this.policePhone,
    required this.picName,
    required this.picPhone,
    required this.keterangan,
    required this.jumlahPoktan,
    required this.jumlahPetani,
    required this.komoditi,
    required this.keteranganLain,
    required this.fotoLahan,
    required this.tglProses,
    required this.diprosesOleh,
    required this.divalidasiOleh,
    required this.tglValidasi,
  });

  factory LandPotentialModel.fromJson(Map<String, dynamic> json) {
    return LandPotentialModel(
      id: json['id']?.toString() ?? '',

      // --- UPDATE DI SINI: Ambil langsung dari hasil JOIN Backend ---
      // Jika null (misal kode wilayah salah), kita tampilkan "-"
      kabupaten:
          (json['nama_kabupaten'] as String?)?.toUpperCase() ??
          "WILAYAH TIDAK DIKETAHUI",
      kecamatan: (json['nama_kecamatan'] as String?)?.toUpperCase() ?? "-",
      desa: (json['nama_desa'] as String?)?.toUpperCase() ?? "-",

      resor:
          "POLRES ${(json['nama_kabupaten'] as String?)?.toUpperCase() ?? '-'}",
      sektor:
          "POLSEK ${(json['nama_kecamatan'] as String?)?.toUpperCase() ?? '-'}",

      jenisLahan: (json['id_jenis_lahan'] == 1) ? 'SAWAH' : 'LADANG',

      luasLahan:
          (json['luas_lahan'] is int)
              ? (json['luas_lahan'] as int).toDouble()
              : (json['luas_lahan'] as double?) ?? 0.0,

      alamatLahan: json['alamat_lahan'] ?? '-',
      statusValidasi: json['status_validasi'] ?? 'BELUM TERVALIDASI',
      policeName: json['police_name'] ?? '-',
      policePhone: json['police_phone'] ?? '-',
      picName: json['pic_name'] ?? '-',
      picPhone: json['pic_phone'] ?? '-',
      keterangan: json['keterangan'] ?? '-',
      jumlahPoktan: json['jumlah_poktan'] ?? 0,
      jumlahPetani: json['jumlah_petani'] ?? 0,
      komoditi: "Jagung",
      keteranganLain: json['keterangan_lain'] ?? '-',
      fotoLahan: json['foto_lahan'] ?? '',
      tglProses: json['tgl_proses'] ?? '-',
      diprosesOleh: json['diproses_oleh'] ?? 'Admin',
      divalidasiOleh: json['divalidasi_oleh'] ?? '-',
      tglValidasi: json['tgl_validasi'] ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_wilayah":
          "3510010", // Sesuaikan dengan kode wilayah pilihan dropdown nanti
      "id_jenis_lahan": (jenisLahan == 'SAWAH') ? 1 : 2,
      "alamat_lahan": alamatLahan,
      "luas_lahan": luasLahan,
      "keterangan": keterangan,
      "pic_name": picName,
      "pic_phone": picPhone,
      "police_name": policeName,
      "police_phone": policePhone,
      "status_validasi": statusValidasi,
      "jumlah_poktan": jumlahPoktan,
      "jumlah_petani": jumlahPetani,
      "komoditi": komoditi,
      "keterangan_lain": keteranganLain,
    };
  }
}
