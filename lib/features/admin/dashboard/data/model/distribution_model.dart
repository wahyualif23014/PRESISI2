class DistributionModel {
  final int total;
  final String label;
  final Map<String, double> breakdown; 

  DistributionModel({
    required this.total,
    required this.label,
    required this.breakdown,
  });

  // Factory Dummy Data
  factory DistributionModel.dummyTitikLahan() {
    return DistributionModel(
      total: 90,
      label: "Total Titik Lahan",
      breakdown: {
        "Terverifikasi": 50.0, // Mewakili warna Biru
        "Belum Verifikasi": 50.0, // Mewakili warna Ungu
      },
    );
  }

  factory DistributionModel.dummyPengelola() {
    return DistributionModel(
      total: 203,
      label: "Pengelolah Lahan Polsek",
      breakdown: {
        "Polri": 85.0, // Mewakili warna Hijau
        "Mitra": 15.0, // Mewakili warna Merah
      },
    );
  }

  // From JSON
  factory DistributionModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> breakdownData = {};
    if (json['breakdown'] != null) {
      (json['breakdown'] as Map<String, dynamic>).forEach((key, value) {
        breakdownData[key] = (value as num).toDouble();
      });
    }

    return DistributionModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      label: json['label'] ?? "-",
      breakdown: breakdownData,
    );
  }
}