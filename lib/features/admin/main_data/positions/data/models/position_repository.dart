// Lokasi: lib/features/admin/main_data/jabatan/data/jabatan_repository.dart

import 'position_model.dart';

class JabatanRepository {
  static List<JabatanModel> getDummyData() {
    return [
      // --- Data Tanpa Pejabat (Sesuai gambar bagian atas) ---
      JabatanModel(
        id: '1',
        namaJabatan: 'KAPOLDA',
      ),
      JabatanModel(
        id: '2',
        namaJabatan: 'WAKAPOLDA',
      ),
      JabatanModel(
        id: '3',
        namaJabatan: 'KAPOLRES',
      ),
      JabatanModel(
        id: '4',
        namaJabatan: 'WAKAPOLRES',
      ),
      JabatanModel(
        id: '5',
        namaJabatan: 'KAPOLSEK',
      ),
      JabatanModel(
        id: '6',
        namaJabatan: 'WAKAPOLSEK',
      ),
      JabatanModel(
        id: '7',
        namaJabatan: 'KAPOLSUBSEKTOR',
      ),

      // --- Data Dengan Pejabat & Tanggal (Sesuai gambar bagian bawah) ---
      JabatanModel(
        id: '8',
        namaJabatan: 'KARO SDM',
        namaPejabat: 'KOMBESPOL ARI WIBOWO, S.I.K., M.H.',
        lastUpdated: '17-11-2025 12:41',
      ),
      JabatanModel(
        id: '9',
        namaJabatan: 'OPERATOR SDM',
        namaPejabat: 'KOMBESPOL ARI WIBOWO, S.I.K., M.H.',
        lastUpdated: '17-11-2025 12:41',
      ),
      JabatanModel(
        id: '10',
        namaJabatan: 'KABAG SDM',
        namaPejabat: 'DIO VLADIKA',
        lastUpdated: '22-12-2025 11:08',
      ),
      JabatanModel(
        id: '11',
        namaJabatan: 'KASATBINMAS',
        namaPejabat: 'KOMBESPOL ARI WIBOWO, S.I.K., M.H.',
        lastUpdated: '17-11-2025 12:41',
      ),
      JabatanModel(
        id: '12',
        namaJabatan: 'PLT. KAPOLRES',
        namaPejabat: 'KOMBESPOL ARI WIBOWO, S.I.K., M.H.',
        lastUpdated: '17-11-2025 12:41',
      ),
    ];
  }
}