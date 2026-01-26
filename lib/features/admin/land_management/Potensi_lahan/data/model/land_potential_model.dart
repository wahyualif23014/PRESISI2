class LandPotentialModel {
  final String id;

  // Header Wilayah (Grouping)
  final String kabupaten;
  final String kecamatan;
  final String desa;

  // Data Kepolisian
  final String resor; // Contoh: "POLSEK BANGKALAN"
  final String sektor; // Contoh: "POLSEK BLEGA"

  // Detail Lahan
  final String jenisLahan; 
  final double luasLahan; // Contoh: 2.00
  final String alamatLahan; // Alamat lengkap jalan/dusun
  final String statusValidasi; // "BELUM TERVALIDASI" / "TERVALIDASI"

  // Personel
  final String policeName; // Polisi Penggerak
  final String policePhone;
  final String picName; // Penanggung Jawab
  final String picPhone;

  // Statistik & Pertanian
  final String keterangan; // Nama Poktan dll
  final int jumlahPoktan;
  final int jumlahPetani;
  final String komoditi; // Contoh: "Tanaman Pangan - Jagung"

  // Dokumentasi
  final String? fotoLahan; // URL Foto (Bisa null jika belum ada)
  final String keteranganLain; // Keterangan tambahan di bawah foto

  // Riwayat Data (Audit Trail)
  final String diprosesOleh;
  final String tglProses;
  final String divalidasiOleh;
  final String tglValidasi;

  // Konstruktor
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
    this.fotoLahan,
    required this.keteranganLain,
    required this.diprosesOleh,
    required this.tglProses,
    required this.divalidasiOleh,
    required this.tglValidasi,
  });

  // Factory JSON (Dengan penanganan Null Safety)
  factory LandPotentialModel.fromJson(Map<String, dynamic> json) {
    return LandPotentialModel(
      id: json['id']?.toString() ?? '',
      kabupaten: json['kabupaten'] ?? '',
      kecamatan: json['kecamatan'] ?? '',
      desa: json['desa'] ?? '',
      resor: json['resor'] ?? '',
      sektor: json['sektor'] ?? '',
      jenisLahan: json['jenis_lahan'] ?? '',
      // Konversi aman ke double (mengatasi int/string dari backend)
      luasLahan:
          (json['luas_lahan'] is int)
              ? (json['luas_lahan'] as int).toDouble()
              : (json['luas_lahan'] as double?) ?? 0.0,
      alamatLahan: json['alamat_lahan'] ?? '',
      statusValidasi: json['status_validasi'] ?? 'BELUM TERVALIDASI',
      policeName: json['police_name'] ?? '',
      policePhone: json['police_phone'] ?? '',
      picName: json['pic_name'] ?? '',
      picPhone: json['pic_phone'] ?? '',
      keterangan: json['keterangan'] ?? '',
      jumlahPoktan: json['jumlah_poktan'] ?? 0,
      jumlahPetani: json['jumlah_petani'] ?? 0,
      komoditi: json['komoditi'] ?? '',
      fotoLahan: json['foto_lahan'], // Bisa null
      keteranganLain: json['keterangan_lain'] ?? '',
      diprosesOleh: json['diproses_oleh'] ?? '',
      tglProses: json['tgl_proses'] ?? '',
      divalidasiOleh: json['divalidasi_oleh'] ?? '',
      tglValidasi: json['tgl_validasi'] ?? '',
    );
  }
}
