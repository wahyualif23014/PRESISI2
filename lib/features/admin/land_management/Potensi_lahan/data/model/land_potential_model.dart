import 'package:latlong2/latlong.dart' show LatLng;

class LandPotentialModel {
  final String id; // idlahan (bigint)
  final String idWilayah; // idwilayah
  final String idTingkat; // idtingkat
  final String kabupaten; // Virtual (Join)
  final String kecamatan; // Virtual (Join)
  final String desa; // Virtual (Join)
  final String resor; // Format UI: POLRES + Kabupaten
  final String sektor; // Format UI: POLSEK + Kecamatan
  final int idJenisLahan; // idjenislahan
  final String jenisLahan; // Virtual (Join)
  final double luasLahan; // luaslahan (decimal)
  final String alamatLahan; // alamat (longtext)
  final String statusValidasi; // statuslahan (enum)
  final String policeName; // cppolisi
  final String policePhone; // hppolisi
  final String picName; // cp
  final String picPhone; // hp
  final String keterangan; // keterangan (longtext)
  final int jumlahPoktan; // poktan
  final int jumlahPetani; // jmlsantri
  final int idKomoditi; // idkomoditi (bigint)
  final String komoditi; // Virtual (Join komoditas)
  final String keteranganLain; // ketlahan (enum)
  final String fotoLahan; // dokumentasi (longtext)
  final String imageUrl; // ImageURL (GORM virtual)
  final String infoProses; // nama_pemroses (Join)
  final String infoValidasi; // nama_validator (Join)
  final double? latitude; // lat
  final double? longitude; // longi

  final String statusPakai; // statuspakai (enum)
  final String statusAktif; // statusaktif (enum)
  final String skLahan; // sk
  final String lembaga; // lembaga
  final String sumberData; // sumberdata
  final String tglProses; // datetransaction
  final String tahunLahan; // tahunlahan

  LandPotentialModel({
    required this.id,
    required this.idWilayah,
    required this.idTingkat,
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
    required this.imageUrl,
    required this.infoProses,
    required this.infoValidasi,
    required this.statusPakai,
    required this.statusAktif,
    required this.skLahan,
    required this.lembaga,
    required this.sumberData,
    required this.tglProses,
    required this.tahunLahan,
    this.latitude,
    this.longitude,
  });

  bool get hasLocation => latitude != null && longitude != null;

  LatLng? get latLng {
    if (hasLocation) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }

  String get ketLainLabel {
    switch (keteranganLain) {
      case '1': return "PRODUKTIF";
      case '2': return "NON-PRODUKTIF";
      case '3': return "LAHAN TIDUR";
      default: return "PRODUKTIF";
    }
  }

  factory LandPotentialModel.fromJson(Map<String, dynamic> json) {
    int jnsLahanId = int.tryParse(json['id_jenis_lahan']?.toString() ?? '0') ?? 0;

    String getJenisLahanTitle(int id) {
      switch (id) {
        case 1: return "MILIK POLRI";
        case 2: return "POKTAN BINAAN POLRI";
        case 3: return "MASYARAKAT BINAAN POLRI";
        case 4: return "TUMPANG SARI";
        case 5: return "PERHUTANAN SOSIAL";
        case 6: return "LBS";
        case 7: return "PESANTREN";
        default: return "LAHAN LAINNYA";
      }
    }

    double? parseCoordinate(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return LandPotentialModel(
      id: json['id']?.toString() ?? '',
      idWilayah: json['id_wilayah']?.toString() ?? '',
      idTingkat: json['id_tingkat']?.toString() ?? '',
      kabupaten: (json['nama_kabupaten'] as String?)?.toUpperCase() ?? "WILAYAH TIDAK DIKETAHUI",
      kecamatan: (json['nama_kecamatan'] as String?)?.toUpperCase() ?? "-",
      desa: (json['nama_desa'] as String?)?.toUpperCase() ?? "-",
      resor: "POLRES ${(json['nama_kabupaten'] as String?)?.toUpperCase() ?? '-'}",
      sektor: "POLSEK ${(json['nama_kecamatan'] as String?)?.toUpperCase() ?? '-'}",
      idJenisLahan: jnsLahanId,
      jenisLahan: getJenisLahanTitle(jnsLahanId),
      luasLahan: double.tryParse(json['luas_lahan']?.toString() ?? '0') ?? 0.0,
      alamatLahan: json['alamat_lahan']?.toString() ?? '-',
      statusValidasi: json['status_validasi']?.toString() ?? '1',
      policeName: json['police_name']?.toString() ?? '-',
      policePhone: json['police_phone']?.toString() ?? '-',
      picName: json['pic_name']?.toString() ?? '-',
      picPhone: json['pic_phone']?.toString() ?? '-',
      keterangan: json['keterangan']?.toString() ?? '-', 
      jumlahPoktan: int.tryParse(json['jumlah_poktan']?.toString() ?? '0') ?? 0,
      jumlahPetani: int.tryParse(json['jumlah_petani']?.toString() ?? '0') ?? 0,
      idKomoditi: int.tryParse(json['id_komoditi']?.toString() ?? '0') ?? 0,
      komoditi: "${json['jenis_komoditas_nama'] ?? 'TANAMAN'}-${json['nama_komoditi_asli'] ?? 'PANGAN'}",
      keteranganLain: json['keterangan_lain']?.toString() ?? '3', 
      fotoLahan: json['foto_lahan']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      infoProses: json['nama_pemroses']?.toString() ?? "-",
      infoValidasi: json['nama_validator']?.toString() ?? "-",
      latitude: parseCoordinate(json['latitude']),
      longitude: parseCoordinate(json['longitude']),
      statusPakai: json['status_pakai']?.toString() ?? '1',
      statusAktif: json['status_aktif']?.toString() ?? '2',
      skLahan: json['sk_lahan']?.toString() ?? '-',
      lembaga: json['lembaga']?.toString() ?? '-',
      sumberData: json['sumber_data']?.toString() ?? '-',
      tglProses: json['tgl_proses']?.toString() ?? '-',
      tahunLahan: json['tahun_lahan']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "id_wilayah": idWilayah,
      "id_tingkat": idTingkat,
      "id_jenis_lahan": idJenisLahan,
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
      "id_komoditi": idKomoditi,
      "keterangan_lain": keteranganLain,
      "foto_lahan": fotoLahan,
      "latitude": latitude,
      "longitude": longitude,
      "status_pakai": statusPakai,
      "status_aktif": statusAktif,
      "sk_lahan": skLahan,
      "lembaga": lembaga,
      "sumber_data": sumberData,
      "tgl_proses": tglProses,
      "tahun_lahan": tahunLahan,
    };
  }

  LandPotentialModel copyWith({
    String? id, String? idWilayah, String? idTingkat, String? kabupaten, String? kecamatan,
    String? desa, String? resor, String? sektor, int? idJenisLahan, String? jenisLahan,
    double? luasLahan, String? alamatLahan, String? statusValidasi, String? policeName,
    String? policePhone, String? picName, String? picPhone, String? keterangan,
    int? jumlahPoktan, int? jumlahPetani, int? idKomoditi, String? komoditi,
    String? keteranganLain, String? fotoLahan, String? imageUrl, String? infoProses,
    String? infoValidasi, double? latitude, double? longitude,
    String? statusPakai, String? statusAktif, String? skLahan, String? lembaga,
    String? sumberData, String? tglProses, String? tahunLahan,
  }) {
    return LandPotentialModel(
      id: id ?? this.id, idWilayah: idWilayah ?? this.idWilayah, idTingkat: idTingkat ?? this.idTingkat,
      kabupaten: kabupaten ?? this.kabupaten, kecamatan: kecamatan ?? this.kecamatan,
      desa: desa ?? this.desa, resor: resor ?? this.resor, sektor: sektor ?? this.sektor,
      idJenisLahan: idJenisLahan ?? this.idJenisLahan, jenisLahan: jenisLahan ?? this.jenisLahan,
      luasLahan: luasLahan ?? this.luasLahan, alamatLahan: alamatLahan ?? this.alamatLahan,
      statusValidasi: statusValidasi ?? this.statusValidasi, policeName: policeName ?? this.policeName,
      policePhone: policePhone ?? this.policePhone, picName: picName ?? this.picName,
      picPhone: picPhone ?? this.picPhone, keterangan: keterangan ?? this.keterangan,
      jumlahPoktan: jumlahPoktan ?? this.jumlahPoktan, jumlahPetani: jumlahPetani ?? this.jumlahPetani,
      idKomoditi: idKomoditi ?? this.idKomoditi, komoditi: komoditi ?? this.komoditi,
      keteranganLain: keteranganLain ?? this.keteranganLain, fotoLahan: fotoLahan ?? this.fotoLahan,
      imageUrl: imageUrl ?? this.imageUrl, infoProses: infoProses ?? this.infoProses,
      infoValidasi: infoValidasi ?? this.infoValidasi, latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      statusPakai: statusPakai ?? this.statusPakai,
      statusAktif: statusAktif ?? this.statusAktif,
      skLahan: skLahan ?? this.skLahan,
      lembaga: lembaga ?? this.lembaga,
      sumberData: sumberData ?? this.sumberData,
      tglProses: tglProses ?? this.tglProses,
      tahunLahan: tahunLahan ?? this.tahunLahan,
    );
  }

  @override
  String toString() {
    return 'LandPotentialModel(id: $id, status: $keteranganLain, validasi: $statusValidasi)';
  }
}