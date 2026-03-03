class LandPotentialModel {
  final String id;
  final String idWilayah;
  final String kabupaten;
  final String kecamatan;
  final String desa;
  final int idJenisLahan;
  final String jenisLahan;
  final double luasLahan;
  final String alamatLahan;
  final String statusValidasi;
  final String policeName;
  final String policePhone;
  final String picName;
  final String picPhone;
  final String keterangan; // Poin 1: Diambil dari kolom ketcp
  final int jumlahPoktan; // Poin 2: Diambil dari kolom poktan
  final int jumlahPetani; // Diambil dari kolom jmlsantri
  final int idKomoditi;
  final String komoditi;
  final String keteranganLain;
  final String fotoLahan;
  final String infoProses; // Poin 3: Nama Anggota (editoleh) & tgl_edit
  final String infoValidasi; // Poin 4: Nama Validator & tgl_valid
  final String namaPemroses;
  final String tglEdit;
  final String namaValidator;
  final String tglValid;
  final String latitude;
  final String longitude;
  final String namaPoktan; // Nama asli kelompok tani dari hasil JOIN

  LandPotentialModel({
    required this.id,
    required this.idWilayah,
    required this.kabupaten,
    required this.kecamatan,
    required this.desa,
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
    required this.namaPemroses,
    required this.tglEdit,
    required this.namaValidator,
    required this.tglValid,
    required this.latitude,
    required this.longitude,
    required this.namaPoktan,
  });

  factory LandPotentialModel.fromJson(Map<String, dynamic> json) {
    int jnsLahanId =
        int.tryParse(json['id_jenis_lahan']?.toString() ?? '0') ?? 0;

    String getJenisLahanTitle(int id) {
      switch (id) {
        case 1:
          return "PRODUKTIF (POKTAN BINAAN POLRI)";
        case 2:
          return "HUTAN (PERHUTANAN SOSIAL)";
        case 3:
          return "LUAS BAKU SAWAH (LBS)";
        case 4:
          return "PESANTREN";
        case 5:
          return "MILIK POLRI";
        case 6:
          return "PRODUKTIF (MASYARAKAT BINAAN POLRI)";
        case 7:
          return "PRODUKTIF (TUMPANG SARI)";
        case 8:
          return "HUTAN (PERHUTANI/INHUTANI)";
        default:
          return "LAHAN LAINNYA";
      }
    }

    // Poin 3: Ambil nama pemroses hasil JOIN tabel anggota dan tanggal edit
    String pemroses = json['nama_pemroses']?.toString() ?? "-";
    String tglEd = json['tgl_edit']?.toString() ?? "-";

    // Poin 4: Ambil nama validator hasil JOIN tabel anggota dan tanggal validasi
    String validator = json['nama_validator']?.toString() ?? "-";
    String tglVal = json['tgl_valid']?.toString() ?? "-";

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
      idJenisLahan: jnsLahanId,
      jenisLahan: getJenisLahanTitle(jnsLahanId),
      luasLahan: double.tryParse(json['luas_lahan']?.toString() ?? '0') ?? 0.0,
      alamatLahan: json['alamat_lahan']?.toString() ?? '-',
      statusValidasi: json['status_validasi']?.toString() ?? '1',
      policeName: json['police_name']?.toString() ?? '-',
      policePhone: json['police_phone']?.toString() ?? '-',
      picName: json['pic_name']?.toString() ?? '-',
      picPhone: json['pic_phone']?.toString() ?? '-',
      // Perbaikan 1: Keterangan dari ketcp
      keterangan: json['keterangan']?.toString() ?? '-',
      // Perbaikan 2: Jumlah Poktan dari kolom poktan
      jumlahPoktan: int.tryParse(json['jumlah_poktan']?.toString() ?? '0') ?? 0,
      jumlahPetani: int.tryParse(json['jumlah_petani']?.toString() ?? '0') ?? 0,
      idKomoditi: int.tryParse(json['id_komoditi']?.toString() ?? '0') ?? 0,
      komoditi: "$jenisKmd - $namaKmd",
      keteranganLain: json['keterangan_lain']?.toString() ?? '-',
      fotoLahan: json['foto_lahan']?.toString() ?? '',
      // Perbaikan 3 & 4: Format tampilan Nama (Waktu)
      infoProses: "$pemroses ($tglEd)",
      infoValidasi:
          (validator == "-" || validator == "") ? "-" : "$validator ($tglVal)",
      namaPemroses: pemroses,
      tglEdit: tglEd,
      namaValidator: validator,
      tglValid: tglVal,
      latitude: json['latitude']?.toString() ?? '0',
      longitude: json['longitude']?.toString() ?? '0',
      namaPoktan: json['nama_poktan_asli']?.toString() ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_wilayah": idWilayah,
      "id_jenis_lahan": idJenisLahan,
      "alamat_lahan": alamatLahan,
      "luas_lahan": luasLahan,
      "poktan": jumlahPoktan, // Mengirim kembali ke kolom poktan
      "pic_name": picName,
      "pic_phone": picPhone,
      "police_name": policeName,
      "police_phone": policePhone,
      "status_validasi": statusValidasi,
      "jumlah_petani": jumlahPetani,
      "id_komoditi": idKomoditi,
      "keterangan": keterangan, // Mengirim kembali ke kolom ketcp melalui alias
      "keterangan_lain": keteranganLain,
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}
