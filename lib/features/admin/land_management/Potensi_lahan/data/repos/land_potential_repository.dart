import '../model/land_potential_model.dart'; // Pastikan path import ini benar

class LandPotentialRepository {
  
  // Simulasi fetch data dari API
  Future<List<LandPotentialModel>> getLandPotentials() async {
    // Simulasi delay network
    await Future.delayed(const Duration(seconds: 1));

    return [
      // --- DATA 1 (BANYUWANGI - KABAT) ---
      LandPotentialModel(
        id: '1',
        // Grouping
        kabupaten: 'BANYUWANGI',
        kecamatan: 'KABAT',
        desa: 'PAKISTAJI',
        
        // Kepolisian
        resor: 'POLRESTA BANYUWANGI',
        sektor: 'POLSEK KABAT',
        
        // Detail Lahan
        jenisLahan: 'LUAS BAKU SAWAH (LBS)',
        luasLahan: 2.00,
        alamatLahan: 'DUSUN KRAJAN DESA PAKISTAJI',
        statusValidasi: 'BELUM TERVALIDASI',
        
        // Personel
        policeName: 'ROSIHUL ULUM',
        policePhone: '+62 812-3359-9704',
        picName: 'SUPRIYANTO',
        picPhone: '+62 857-3216-4867',
        
        // Statistik
        keterangan: 'NAMA POKTAN SUMBER REJEKI',
        jumlahPoktan: 1,
        jumlahPetani: 50,
        komoditi: 'Tanaman Pangan - Jagung',
        
        // Dokumentasi & Audit
        fotoLahan: 'https://upload.wikimedia.org/wikipedia/commons/9/92/Rice_fields_in_Bali.jpg',
        keteranganLain: 'Lahan produktif milik warga yang dikelola bersama.',
        diprosesOleh: 'BRIPKA M. RIFAN FAUJI',
        tglProses: '18-01-2026 19:44',
        divalidasiOleh: '-',
        tglValidasi: '-',
      ),
      
      // --- DATA 2 (BANYUWANGI - KABAT - DESA SAMA) ---
      LandPotentialModel(
        id: '2',
        kabupaten: 'BANYUWANGI',
        kecamatan: 'KABAT',
        desa: 'PAKISTAJI',
        
        resor: 'POLRESTA BANYUWANGI',
        sektor: 'POLSEK KABAT',
        
        jenisLahan: 'PEKARANGAN PANGAN LESTARI',
        luasLahan: 0.5,
        alamatLahan: 'JL. RAYA KABAT NO. 45',
        statusValidasi: 'TERVALIDASI',
        
        policeName: 'BUDI SANTOSO',
        policePhone: '+62 813-5555-6666',
        picName: 'H. AHMAD',
        picPhone: '+62 819-8888-9999',
        
        keterangan: 'KWT MAWAR MELATI',
        jumlahPoktan: 1,
        jumlahPetani: 20,
        komoditi: 'Sayuran - Cabai & Tomat',
        
        fotoLahan: null, // Test jika foto kosong
        keteranganLain: 'Pemanfaatan pekarangan rumah warga.',
        diprosesOleh: 'AIPDA JOKO',
        tglProses: '10-01-2026 08:00',
        divalidasiOleh: 'AKP SURYONO',
        tglValidasi: '12-01-2026 10:30',
      ),

      // --- DATA 3 (BANYUWANGI - ROGOJAMPI - BEDA KECAMATAN) ---
      LandPotentialModel(
        id: '3',
        kabupaten: 'BANYUWANGI',
        kecamatan: 'ROGOJAMPI',
        desa: 'GLAGAH AGUNG',
        
        resor: 'POLRESTA BANYUWANGI',
        sektor: 'POLSEK ROGOJAMPI',
        
        jenisLahan: 'LAHAN TIDUR',
        luasLahan: 5.00,
        alamatLahan: 'TANAH KAS DESA GLAGAH',
        statusValidasi: 'BELUM TERVALIDASI',
        
        policeName: 'SGT. TEJO',
        policePhone: '+62 811-1234-5678',
        picName: 'KEPALA DESA',
        picPhone: '+62 812-4321-8765',
        
        keterangan: 'Rencana pembukaan lahan baru',
        jumlahPoktan: 0,
        jumlahPetani: 0,
        komoditi: 'Belum Ada',
        
        fotoLahan: 'https://cdn.pixabay.com/photo/2016/11/14/03/29/grand-canyon-1822459_1280.jpg',
        keteranganLain: 'Tanah perlu pembersihan semak belukar.',
        diprosesOleh: 'BRIPTU DENI',
        tglProses: '20-01-2026 14:00',
        divalidasiOleh: '-',
        tglValidasi: '-',
      ),

      // --- DATA 4 (BANGKALAN - CONTOH DATA GAMBAR) ---
      LandPotentialModel(
        id: '4',
        kabupaten: 'BANGKALAN',
        kecamatan: 'BLEGA',
        desa: 'KARANG GAYAM',
        
        resor: 'POLRES BANGKALAN',
        sektor: 'POLSEK BLEGA',
        
        jenisLahan: 'LUAS BAKU SAWAH (LBS)',
        luasLahan: 2.00,
        alamatLahan: 'DUSUN BANDUNGAN DESA KARANG GAYAM',
        statusValidasi: 'TERVALIDASI',
        
        policeName: 'ROSIHUL ULUM',
        policePhone: '+62 812-3359-9704',
        picName: 'SUPRIYANTO',
        picPhone: '+62 857-3216-4867',
        
        keterangan: 'NAMA POKTAN BANDUNG RAYA ( KA POKTAN / SUPRIYANTO )',
        jumlahPoktan: 1,
        jumlahPetani: 50,
        komoditi: 'Tanaman Pangan - Jagung',
        
        fotoLahan: 'https://upload.wikimedia.org/wikipedia/commons/9/92/Rice_fields_in_Bali.jpg',
        keteranganLain: 'DALAM LUAS LAHAN SELUAS 2 HA TERSEBUT TERDIRI DARI BEBERAPA LAHAN MILIK ANGGOTA KELOMPOK TANI',
        diprosesOleh: 'BRIPKA M. RIFAN FAUJI',
        tglProses: '18-01-2026 19:44',
        divalidasiOleh: 'AIPDA DWI ACHMAT EFENDI',
        tglValidasi: '19-01-2026 15:46',
      ),
    ];
  }
  
  // Simulasi get Summary Data
  Future<Map<String, dynamic>> getSummaryStats() async {
     await Future.delayed(const Duration(milliseconds: 500));
     return {
       'total_potensi_lahan': '674.18 HA',
       'polres_no_data': 17
     };
  }
}