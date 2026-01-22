import '../model/recap_model.dart';

class RecapRepo {
  // Simulasi fetch data dari API
  Future<List<RecapModel>> getRecapData() async {
    await Future.delayed(const Duration(seconds: 1));
    return _dummyData;
  }

  static final List<RecapModel> _dummyData = [
    // --- LEVEL 1: POLRES (Header Utama) ---
    RecapModel(
      id: '1',
      namaWilayah: 'POLRES BANGKALAN',
      potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0,
      type: RecapRowType.polres, // <--- Tipe Polres
    ),

    // --- LEVEL 2: POLSEK AROSBAYA ---
    RecapModel(
      id: '1-1',
      namaWilayah: 'POLSEK AROSBAYA',
      potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0,
      type: RecapRowType.polsek, // <--- Tipe Polsek
    ),

    // --- LEVEL 3: DESA DI BAWAH AROSBAYA ---
    // (Berdasarkan gambar, meski kecamatannya tertulis Konang, strukturnya ada di bawah header Polsek Arosbaya)
    RecapModel(id: '1-1-a', namaWilayah: 'DESA DURIN BARAT KEC. KONANG', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0, type: RecapRowType.desa),
    RecapModel(id: '1-1-b', namaWilayah: 'DESA BANDUNG KEC. KONANG', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0, type: RecapRowType.desa),
    RecapModel(id: '1-1-c', namaWilayah: 'DESA BATOKABAN KEC. KONANG', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0, type: RecapRowType.desa),
    
    // --- LEVEL 2: POLSEK GALIS (Contoh Polsek Lain) ---
    RecapModel(
      id: '1-2',
      namaWilayah: 'POLSEK GALIS',
      potensiLahan: 12, tanamLahan: 2, panenLuas: 0, panenTon: 0, serapan: 0,
      type: RecapRowType.polsek,
    ),
    
    // --- LEVEL 3: DESA DI BAWAH GALIS ---
    RecapModel(id: '1-2-a', namaWilayah: 'DESA GALIS TIMUR', potensiLahan: 6, tanamLahan: 1, panenLuas: 0, panenTon: 0, serapan: 0, type: RecapRowType.desa),
    RecapModel(id: '1-2-b', namaWilayah: 'DESA GALIS BARAT', potensiLahan: 6, tanamLahan: 1, panenLuas: 0, panenTon: 0, serapan: 0, type: RecapRowType.desa),


    // --- CONTOH LAIN: POLRES SAMPANG ---
    RecapModel(
      id: '2',
      namaWilayah: 'POLRES SAMPANG',
      potensiLahan: 20, tanamLahan: 5, panenLuas: 1, panenTon: 5, serapan: 1,
      type: RecapRowType.polres,
    ),
    RecapModel(
      id: '2-1',
      namaWilayah: 'POLSEK BANYUATES',
      potensiLahan: 10, tanamLahan: 2, panenLuas: 0, panenTon: 0, serapan: 0,
      type: RecapRowType.polsek,
    ),
    RecapModel(id: '2-1-a', namaWilayah: 'DESA BANYUATES A', potensiLahan: 10, tanamLahan: 2, panenLuas: 0, panenTon: 0, serapan: 0, type: RecapRowType.desa),
  ];
}