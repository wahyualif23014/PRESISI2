class LandPotentialModel {
  final String id;
  final String kabupaten; // Untuk Group Header 1 (Ungu Tua)
  final String kecamatanDesa; // Untuk Group Header 2 (Ungu Muda)
  
  // Data Polisi Penggerak
  final String policeName;
  final String policePhone;
  
  // Data Penanggung Jawab (PJ)
  final String picName;
  final String picPhone;
  
  // Detail Lahan
  final String address;
  final String statusValidasi; // Contoh: "BELUM VALIDASI" or "TERVALIDASI"
  
  // Konstruktor
  LandPotentialModel({
    required this.id,
    required this.kabupaten,
    required this.kecamatanDesa,
    required this.policeName,
    required this.policePhone,
    required this.picName,
    required this.picPhone,
    required this.address,
    required this.statusValidasi,
  });

  // Factory untuk convert dari JSON (Persiapan integrasi API)
  factory LandPotentialModel.fromJson(Map<String, dynamic> json) {
    return LandPotentialModel(
      id: json['id'] ?? '',
      kabupaten: json['kabupaten'] ?? '',
      kecamatanDesa: json['kecamatan_desa'] ?? '',
      policeName: json['police_name'] ?? '',
      policePhone: json['police_phone'] ?? '',
      picName: json['pic_name'] ?? '',
      picPhone: json['pic_phone'] ?? '',
      address: json['address'] ?? '',
      statusValidasi: json['status_validasi'] ?? 'BELUM VALIDASI',
    );
  }

  // Method to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kabupaten': kabupaten,
      'kecamatan_desa': kecamatanDesa,
      'police_name': policeName,
      'police_phone': policePhone,
      'pic_name': picName,
      'pic_phone': picPhone,
      'address': address,
      'status_validasi': statusValidasi,
    };
  }
}