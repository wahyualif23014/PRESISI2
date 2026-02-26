import 'package:latlong2/latlong.dart' show LatLng;

class LandPotentialModel {
  final String id;
  final String idWilayah; // Kode Geografis (NOT NULL)
  final String idTingkat; // Kode Kesatuan (NOT NULL)
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
  final String keterangan; // Deskripsi Panjang (Longtext)
  final int jumlahPoktan;
  final int jumlahPetani;
  final int idKomoditi;
  final String komoditi;
  final String keteranganLain; // ENUM '1', '2', '3' (ketlahan)
  final String fotoLahan; // Base64 String untuk Upload
  final String imageUrl; // URL untuk Menampilkan Gambar
  final String infoProses;
  final String infoValidasi;
  final double? latitude;
  final double? longitude;

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

  // Helper untuk mendapatkan Label Human-Readable dari ENUM DB
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
        case 1: return "PERHUTANAN SOSIAL";
        case 2: return "POKTAN BINAAN POLRI";
        case 3: return "MASYARAKAT BINAAN POLRI";
        case 4: return "TUMPANG SARI";
        case 5: return "MILIK POLRI";
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
      statusValidasi: json['status_validasi']?.toString() ?? 'BELUM TERVALIDASI',
      policeName: json['police_name']?.toString() ?? '-',
      policePhone: json['police_phone']?.toString() ?? '-',
      picName: json['pic_name']?.toString() ?? '-',
      picPhone: json['pic_phone']?.toString() ?? '-',
      keterangan: json['keterangan']?.toString() ?? '-', 
      jumlahPoktan: int.tryParse(json['jumlah_poktan']?.toString() ?? '0') ?? 0,
      jumlahPetani: int.tryParse(json['jumlah_petani']?.toString() ?? '0') ?? 0,
      idKomoditi: int.tryParse(json['id_komoditi']?.toString() ?? '0') ?? 0,
      komoditi: "${json['jenis_komoditas_nama'] ?? 'TANAMAN'}-${json['nama_komoditi_asli'] ?? 'PANGAN'}",
      keteranganLain: json['keterangan_lain']?.toString() ?? '1', // Sesuai tag JSON backend
      fotoLahan: json['foto_lahan']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      infoProses: json['nama_pemroses']?.toString() ?? "-",
      infoValidasi: json['nama_validator']?.toString() ?? "-",
      latitude: parseCoordinate(json['latitude']),
      longitude: parseCoordinate(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      "status_validasi": statusValidasi, // Akan diproses backend ke ENUM 1-4
      "jumlah_poktan": jumlahPoktan,
      "jumlah_petani": jumlahPetani,
      "id_komoditi": idKomoditi,
      "keterangan_lain": keteranganLain, // MENGIRIM '1', '2', ATAU '3' (Konsisten)
      "foto_lahan": fotoLahan,
      "latitude": latitude,
      "longitude": longitude,
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
    );
  }

  @override
  String toString() {
    return 'LandPotentialModel(id: $id, tingkat: $idTingkat, wilayah: $idWilayah, status: $keteranganLain)';
  }
}