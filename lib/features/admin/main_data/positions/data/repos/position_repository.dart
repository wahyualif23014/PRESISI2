// Lokasi: lib/features/admin/main_data/jabatan/data/repos/jabatan_repository.dart

import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/models/position_model.dart';

// Import http jika nanti sudah connect API
// import 'package:http/http.dart' as http; 
// import 'dart:convert';

class JabatanRepository {
  
  // ---------------------------------------------------------------------------
  static Future<List<JabatanModel>> getJabatanList() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      JabatanModel(
        id: '1',
        namaJabatan: 'Kapolres Metro Jakarta Selatan',
        namaPejabat: 'Kombes Pol. Ade Rahmat Idnal',
        nrp: '75090881',
        tanggalPeresmian: '2023-12-15',
      ),
      JabatanModel(
        id: '2',
        namaJabatan: 'Wakapolres Metro Jakarta Selatan',
        namaPejabat: 'AKBP Antonius Agus Rahmanto',
        nrp: '79101122',
        tanggalPeresmian: '2024-01-10',
      ),
      JabatanModel(
        id: '3',
        namaJabatan: 'Kasat Reskrim',
        namaPejabat: 'AKBP Bintoro',
        nrp: '82050341',
        tanggalPeresmian: '2023-08-20',
      ),
      JabatanModel(
        id: '4',
        namaJabatan: 'Kasat Lantas',
        namaPejabat: 'Kompol Yunita Natalia Rungkat',
        nrp: '85031200',
        tanggalPeresmian: '2023-11-05',
      ),
      JabatanModel(
        id: '5',
        namaJabatan: 'Kabag Ops',
        namaPejabat: 'AKBP Gunanto',
        nrp: '78020999',
        tanggalPeresmian: '2022-05-12',
      ),
      JabatanModel(
        id: '6',
        namaJabatan: 'Kapolsek Kebayoran Baru',
        namaPejabat: 'Kompol Tribuana Roseno',
        nrp: '87010011',
        tanggalPeresmian: '2024-02-01',
      ),
      JabatanModel(
        id: '7',
        namaJabatan: 'Kanit Binmas',
        namaPejabat: null, // Contoh Jabatan Kosong
        nrp: null,
        tanggalPeresmian: null,
      ),
      JabatanModel(
        id: '8',
        namaJabatan: 'Bhabinkamtibmas Kel. Cipete Utara',
        namaPejabat: 'Aipda Deni Anggoro',
        nrp: '90010203',
        tanggalPeresmian: '2021-06-15',
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // OPSI 2: CONTOH IMPLEMENTASI KE BACKEND (Simpan untuk nanti)
  // ---------------------------------------------------------------------------
  /*
  static Future<List<JabatanModel>> fetchFromApi() async {
    final url = Uri.parse('https://api.kepolisian.go.id/v1/jabatan');
    
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer YOUR_TOKEN_HERE',
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body)['data'];
        
        // Konversi JSON ke List<JabatanModel>
        return jsonList.map((json) => JabatanModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }
  */
}