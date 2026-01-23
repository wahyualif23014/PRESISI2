import '../model/land_potential_model.dart'; // Pastikan import model yang dibuat di atas

class LandPotentialRepository {
  
  // Simulasi fetch data dari API
  Future<List<LandPotentialModel>> getLandPotentials() async {
    // Simulasi delay network
    await Future.delayed(const Duration(seconds: 1));

    return [
      // --- DATA 1 ---
      LandPotentialModel(
        id: '1',
        kabupaten: 'KABUPATEN BANYUWANGI',
        kecamatanDesa: 'KECAMATAN KABAT DESA PAKISTAJI',
        policeName: 'ROSIHUL ULUM',
        policePhone: '+62 812-3359-9704',
        picName: 'SUPRIYANTO',
        picPhone: '+62 857-3216-4867',
        address: 'DUSUN BANDUNGAN DESA KARANG GAYAM KEC. BLEGA KAB. BANGKALAN',
        statusValidasi: 'BELUM VALIDASI',
      ),
      
      // --- DATA 2 ---
      LandPotentialModel(
        id: '2',
        kabupaten: 'KABUPATEN BANYUWANGI',
        kecamatanDesa: 'KECAMATAN KABAT DESA PAKISTAJI',
        policeName: 'ROSIHUL ULUM',
        policePhone: '+62 812-3359-9704',
        picName: 'SUPRIYANTO',
        picPhone: '+62 857-3216-4867',
        address: 'DUSUN BANDUNGAN DESA KARANG GAYAM KEC. BLEGA KAB. BANGKALAN',
        statusValidasi: 'BELUM VALIDASI',
      ),

      // --- DATA 3 ---
      LandPotentialModel(
        id: '3',
        kabupaten: 'KABUPATEN BANYUWANGI',
        kecamatanDesa: 'KECAMATAN KABAT DESA PAKISTAJI',
        policeName: 'ROSIHUL ULUM',
        policePhone: '+62 812-3359-9704',
        picName: 'SUPRIYANTO',
        picPhone: '+62 857-3216-4867',
        address: 'DUSUN BANDUNGAN DESA KARANG GAYAM KEC. BLEGA KAB. BANGKALAN',
        statusValidasi: 'BELUM VALIDASI',
      ),

      // --- DATA 4 (Contoh data lain untuk testing grouping) ---
      LandPotentialModel(
        id: '4',
        kabupaten: 'KABUPATEN BANYUWANGI',
        kecamatanDesa: 'KECAMATAN KABAT DESA PAKISTAJI',
        policeName: 'ROSIHUL ULUM',
        policePhone: '+62 812-3359-9704',
        picName: 'SUPRIYANTO',
        picPhone: '+62 857-3216-4867',
        address: 'DUSUN BANDUNGAN DESA KARANG GAYAM KEC. BLEGA KAB. BANGKALAN',
        statusValidasi: 'BELUM VALIDASI',
      ),
      
      // --- DATA 5 (Contoh beda kecamatan) ---
      LandPotentialModel(
        id: '5',
        kabupaten: 'KABUPATEN BANYUWANGI',
        kecamatanDesa: 'KECAMATAN ROGOJAMPI DESA GLAGAH', // Beda Kecamatan
        policeName: 'BUDI SANTOSO',
        policePhone: '+62 811-0000-1111',
        picName: 'AHMAD JAILANI',
        picPhone: '+62 812-2222-3333',
        address: 'JL. RAYA ROGOJAMPI NO. 12',
        statusValidasi: 'TERVALIDASI',
      ),
    ];
  }
  
  // Simulasi get Summary Data (Untuk Header yang 674.18 HA)
  Future<Map<String, dynamic>> getSummaryStats() async {
     await Future.delayed(const Duration(milliseconds: 500));
     return {
       'total_potensi_lahan': '674.18 HA',
       'polres_no_data': 17
     };
  }
}