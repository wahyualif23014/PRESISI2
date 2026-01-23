import '../model/land_summary_model.dart'; // Sesuaikan path import

class LandSummaryRepository {
  
  Future<LandSummaryModel> getSummaryData() async {
    // Simulasi delay network
    await Future.delayed(const Duration(milliseconds: 500));

    // Data Dummy sesuai gambar Alert 3.png
    return LandSummaryModel(
      totalArea: 21313.03,
      totalLocations: 1350,
      details: [
        LandSummaryItem(title: "Milik Polri", area: 6.59, locationCount: 5),
        LandSummaryItem(title: "Masyarakat Binaan Polri", area: 6.59, locationCount: 5),
        LandSummaryItem(title: "Perhutanan Sosial", area: 6.59, locationCount: 5),
        LandSummaryItem(title: "Pesantren", area: 6.59, locationCount: 5),
        LandSummaryItem(title: "Poktan Binaan Polri", area: 6.59, locationCount: 5),
        LandSummaryItem(title: "Tumpang Sari", area: 6.59, locationCount: 5),
        LandSummaryItem(title: "LBS", area: 6.59, locationCount: 5),
        LandSummaryItem(title: "Lainnya", area: 6.59, locationCount: 5),
        LandSummaryItem(title: "Polres", area: 6.59, locationCount: 5),
        LandSummaryItem(title: "Polsek", area: 6.59, locationCount: 5),
        LandSummaryItem(title: "KAB/KOTA", area: 6.59, locationCount: 5),
        LandSummaryItem(title: "KECAMATAN", area: 6.59, locationCount: 5),
        LandSummaryItem(title: "KEL/DESA", area: 6.59, locationCount: 5),
      ],
    );
  }
}