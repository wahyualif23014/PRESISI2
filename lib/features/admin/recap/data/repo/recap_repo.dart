import '../model/recap_model.dart';

class RecapRepo {
  // Simulasi fetch data dari API
  Future<List<RecapModel>> getRecapData() async {
    // Simulasi delay network
    await Future.delayed(const Duration(seconds: 1));
    return _dummyData;
  }

  // --- DUMMY DATA SESUAI SCREENSHOT ---
  static final List<RecapModel> _dummyData = [
    // HEADER: POLRES BANGKALAN
    RecapModel(
      id: '1',
      namaWilayah: 'POLRES BANGKALAN',
      potensiLahan: 8,
      tanamLahan: 0,
      panenLuas: 0,
      panenTon: 0,
      serapan: 0,
      isHeader: true, // Latar Ungu
    ),
    // LIST ITEMS: POLSEK
    RecapModel(id: '1-1', namaWilayah: 'POLSEK AROSBAYA', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0),
    RecapModel(id: '1-2', namaWilayah: 'POLSEK BLEGA', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0),
    RecapModel(id: '1-3', namaWilayah: 'POLSEK BURNER', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0),
    RecapModel(id: '1-4', namaWilayah: 'POLSEK GALIS', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0),
    RecapModel(id: '1-5', namaWilayah: 'POLSEK GEGER', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0),
    RecapModel(id: '1-6', namaWilayah: 'POLSEK KLAMPIS', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0),
    RecapModel(id: '1-7', namaWilayah: 'POLSEK KAMAL', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0),
    RecapModel(id: '1-8', namaWilayah: 'POLSEK KOKOP', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0),
    RecapModel(id: '1-9', namaWilayah: 'POLSEK KWANYAR', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0),
    RecapModel(id: '1-10', namaWilayah: 'POLSEK KONANG', potensiLahan: 8, tanamLahan: 0, panenLuas: 0, panenTon: 0, serapan: 0),
    
    // HEADER: POLRES SAMPANG (Contoh tambahan jika list berlanjut)
    RecapModel(
      id: '2',
      namaWilayah: 'POLRES SAMPANG',
      potensiLahan: 12,
      tanamLahan: 2,
      panenLuas: 1,
      panenTon: 5,
      serapan: 1,
      isHeader: true,
    ),
    RecapModel(id: '2-1', namaWilayah: 'POLSEK BANYUATES', potensiLahan: 12, tanamLahan: 2, panenLuas: 1, panenTon: 5, serapan: 1),
  ];
}