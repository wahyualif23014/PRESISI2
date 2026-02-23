class LandPotentialModel {
  final String id;
  final String idWilayah;
  final String kabupaten;
  final String kecamatan;
  final String desa;
  final String resor;
  final String sektor;
  final int idJenisLahan;
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
  final int idKomoditi;
  final String komoditi;
  final String keteranganLain;
  final String fotoLahan;
  final String infoProses;
  final String infoValidasi;

  LandPotentialModel({
    required this.id,
    required this.idWilayah,
    required this.kabupaten,
    required this.kecamatan,
    required this.desa,
    required this.resor,
    required this.sektor,
    required this.idJenisLahan,
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
    required this.idKomoditi,
    required this.komoditi,
    required this.keteranganLain,
    required this.fotoLahan,
    required this.infoProses,
    required this.infoValidasi,
  });

  factory LandPotentialModel.fromJson(Map<String, dynamic> json) {
    int jnsLahanId =
        int.tryParse(json['id_jenis_lahan']?.toString() ?? '0') ?? 0;

    String getJenisLahanTitle(int id) {
      switch (id) {
        case 1:
          return "PERHUTANAN SOSIAL";
        case 2:
          return "POKTAN BINAAN POLRI";
        case 3:
          return "MASYARAKAT BINAAN POLRI";
        case 4:
          return "TUMPANG SARI";
        case 5:
          return "MILIK POLRI";
        case 6:
          return "LBS";
        case 7:
          return "PESANTREN";
        default:
          return "LAHAN LAINNYA";
      }
    }

    // Ambil data pemroses dari JOIN tabel anggota
    String namaPemroses = json['nama_pemroses']?.toString() ?? "-";
    String tglEdit = json['tgl_proses']?.toString() ?? "-";

    // Ambil data validator dari JOIN tabel anggota
    String namaValidator = json['nama_validator']?.toString() ?? "-";
    String tglValidasi = json['tgl_validasi']?.toString() ?? "-";

    // Ambil data komoditi dengan alias nama_komoditi_asli agar tidak tertukar
    String jenisKmd =
        (json['jenis_komoditas_nama'] ?? "TANAMAN PANGAN")
            .toString()
            .toUpperCase();
    String namaKmd =
        (json['nama_komoditi_asli'] ?? "JAGUNG").toString().toUpperCase();

    return LandPotentialModel(
      id: json['id']?.toString() ?? '',
      idWilayah: json['id_wilayah']?.toString() ?? '',
      kabupaten:
          (json['nama_kabupaten'] as String?)?.toUpperCase() ??
          "WILAYAH TIDAK DIKETAHUI",
      kecamatan: (json['nama_kecamatan'] as String?)?.toUpperCase() ?? "-",
      desa: (json['nama_desa'] as String?)?.toUpperCase() ?? "-",
      resor:
          "POLRES ${(json['nama_kabupaten'] as String?)?.toUpperCase() ?? '-'}",
      sektor:
          "POLSEK ${(json['nama_kecamatan'] as String?)?.toUpperCase() ?? '-'}",
      idJenisLahan: jnsLahanId,
      jenisLahan: getJenisLahanTitle(jnsLahanId),
      luasLahan: double.tryParse(json['luas_lahan']?.toString() ?? '0') ?? 0.0,
      alamatLahan: json['alamat_lahan']?.toString() ?? '-',
      statusValidasi:
          json['status_validasi']?.toString() ?? 'BELUM TERVALIDASI',
      policeName: json['police_name']?.toString() ?? '-',
      policePhone: json['police_phone']?.toString() ?? '-',
      picName: json['pic_name']?.toString() ?? '-',
      picPhone: json['pic_phone']?.toString() ?? '-',
      keterangan: json['poktan']?.toString() ?? '-', // Mapping ke kolom poktan
      jumlahPoktan: int.tryParse(json['jumlah_poktan']?.toString() ?? '0') ?? 0,
      jumlahPetani: int.tryParse(json['jumlah_petani']?.toString() ?? '0') ?? 0,
      idKomoditi: int.tryParse(json['id_komoditi']?.toString() ?? '0') ?? 0,
      komoditi: "$jenisKmd-$namaKmd",
      keteranganLain: json['keterangan_lain']?.toString() ?? '-',
      fotoLahan: json['foto_lahan']?.toString() ?? '',
      infoProses: "$namaPemroses ($tglEdit)",
      infoValidasi:
          namaValidator == "-" ? "-" : "$namaValidator ($tglValidasi)",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_wilayah": idWilayah,
      "id_jenis_lahan": idJenisLahan,
      "alamat_lahan": alamatLahan,
      "luas_lahan": luasLahan,
      "poktan": keterangan,
      "pic_name": picName,
      "pic_phone": picPhone,
      "police_name": policeName,
      "police_phone": policePhone,
      "status_validasi": statusValidasi,
      "jumlah_poktan": jumlahPoktan,
      "jumlah_petani": jumlahPetani,
      "id_komoditi": idKomoditi,
      "keterangan_lain": keteranganLain,
    };
  }
}
