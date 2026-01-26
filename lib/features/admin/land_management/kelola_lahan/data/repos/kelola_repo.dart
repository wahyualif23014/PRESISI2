import 'package:sdmapp/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';


class LandManagementRepository {
  
  // 1. GET SUMMARY DATA (Header Stats)
  Future<LandManagementSummaryModel> getSummaryStats() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulasi API

    return LandManagementSummaryModel(
      totalPotensiLahan: 6124.35,
      totalTanamLahan: 620.45,
      totalPanenLahanHa: 3.20,
      totalPanenLahanTon: 16.00,
      totalSerapanTon: 0.00,
    );
  }

  // 2. GET LIST DATA (Table Rows)
  Future<List<LandManagementItemModel>> getLandManagementList() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulasi API

    // Data Dummy Sesuai Gambar
    return [
      // --- ITEM 1 ---
      LandManagementItemModel(
        id: '1',
        regionGroup: 'KAB. BANGKALAN KEC. AROSBAYA DESA DLEMER',
        subRegionGroup: 'DUSUN RONCEH',
        policeName: 'BAMBANG PRIONO',
        policePhone: '+62 878-4523-7310',
        picName: 'ROHMATULLOH',
        picPhone: '+62 838-5284-3164',
        landArea: 0.74,
        status: 'PROSES PANEN',
        statusColor: '#FF9800', // Orange
      ),

      // --- ITEM 2 (Beda Dusun/Sub Region) ---
      LandManagementItemModel(
        id: '2',
        regionGroup: 'KAB. BANGKALAN KEC. AROSBAYA DESA LAJING',
        subRegionGroup: 'DUSUN BARUK',
        policeName: 'YUNUS SETYA BUDI',
        policePhone: '+62 823-3202-6519',
        picName: 'RUDY AFFANDI',
        picPhone: '+62 877-1832-6635',
        landArea: 0.74,
        status: 'PROSES PANEN',
        statusColor: '#FF9800',
      ),

      // --- ITEM 3 ---
      LandManagementItemModel(
        id: '3',
        regionGroup: 'KAB. BANGKALAN KEC. AROSBAYA DESA PLAKARAN',
        subRegionGroup: 'DUSUN PLAKARAN',
        policeName: 'RUDI HARTONO',
        policePhone: '+62 812-1719-8527',
        picName: 'ROHMATULLOH',
        picPhone: '+62 838-5284-3164',
        landArea: 0.74,
        status: 'PROSES PANEN',
        statusColor: '#FF9800',
      ),

      // --- ITEM 4 (Contoh grouping sama dengan item 1 untuk tes UI grouping) ---
      LandManagementItemModel(
        id: '4',
        regionGroup: 'KAB. BANGKALAN KEC. AROSBAYA DESA DLEMER',
        subRegionGroup: 'DUSUN RONCEH',
        policeName: 'LINBAMBANG PRIONO',
        policePhone: '+62 878-4523-7310',
        picName: 'ROHMATULLOH',
        picPhone: '+62 838-5284-3164',
        landArea: 0.74,
        status: 'PROSES PANEN',
        statusColor: '#FF9800',
      ),
      
      // --- ITEM 5 (Contoh data lain) ---
      LandManagementItemModel(
        id: '5',
        regionGroup: 'KAB. BANGKALAN KEC. BLEGA DESA KARANG GAYAM',
        subRegionGroup: 'DUSUN RONCEH',
        policeName: 'LINBAMBANG PRIONO',
        policePhone: '+62 878-4523-7310',
        picName: 'ROHMATULLOH',
        picPhone: '+62 838-5284-3164',
        landArea: 0.74,
        status: 'PROSES PANEN',
        statusColor: '#FF9800',
      ),
    ];
  }
}