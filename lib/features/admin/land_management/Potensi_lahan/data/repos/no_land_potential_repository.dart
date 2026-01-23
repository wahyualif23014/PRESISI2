import '../model/no_land_potential_model.dart'; // Sesuaikan path import

class NoLandPotentialRepository {
  
  Future<NoLandPotentialModel> getNoLandData() async {
    // Simulasi delay network
    await Future.delayed(const Duration(milliseconds: 500));

    // Data Dummy
    return NoLandPotentialModel(
      totalPolres: 17, // Angka di Header (Alert 2)
      details: [
        // Data Rincian (Struktur Alert 4)
        NoLandDetailItem(label: "Polsek", count: 300),
        NoLandDetailItem(label: "Kabupaten / Kota", count: 1),
        NoLandDetailItem(label: "Kecamatan", count: 306),
        NoLandDetailItem(label: "Kelurahan/ Desa", count: 7501),
      ],
    );
  }
}