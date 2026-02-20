import '../models/lahan_history_model.dart';

class LandHistoryRepository {
  
  // 1. GET SUMMARY STATS
  Future<LandHistorySummaryModel> getSummaryStats() async {
    await Future.delayed(const Duration(milliseconds: 500)); 

    return LandHistorySummaryModel(
      totalPotensiLahan: 6124.35,
      totalTanamLahan: 620.45,
      totalPanenLahanHa: 3.20,
      totalPanenLahanTon: 16.00,
      totalSerapanTon: 0.00,
    );
  }

  // 2. GET HISTORY LIST
  Future<List<LandHistoryItemModel>> getHistoryList() async {
    await Future.delayed(const Duration(milliseconds: 800)); 

    return [
      LandHistoryItemModel(
        id: '1',
        regionGroup: 'KAB. BANGKALAN KEC. AROSBAYA DESA DLEMER',
        subRegionGroup: 'DUSUN RONCEH',
        policeName: 'BAMBANG PRIONO',
        policePhone: '+62 878-4523-7310',
        picName: 'ROHMATULLOH',
        picPhone: '+62 838-5284-3164',
        landArea: 3.50,
        landCategory: 'POKTAN BINAAN POLRI', // Teks kecil di bawah luas
        status: 'PROSES PANEN',
        statusColor: '#FF9800', 
      ),

      // --- GRUP 2: LAJING / BARUK ---
      LandHistoryItemModel(
        id: '2',
        regionGroup: 'KAB. BANGKALAN KEC. AROSBAYA DESA LAJING',
        subRegionGroup: 'DUSUN BARUK',
        policeName: 'YUNUS SETYA BUDI',
        policePhone: '+62 823-3202-6519',
        picName: 'RUDY AFFANDI',
        picPhone: '+62 877-1832-6635',
        landArea: 1.50,
        landCategory: 'POKTAN BINAAN POLRI',
        status: 'PROSES PANEN',
        statusColor: '#FF9800',
      ),

      // --- GRUP 3: PLAKARAN / PLAKARAN (Item A) ---
      LandHistoryItemModel(
        id: '3',
        regionGroup: 'KAB. BANGKALAN KEC. AROSBAYA DESA PLAKARAN',
        subRegionGroup: 'DUSUN PLAKARAN',
        policeName: 'RUDI HARTONO',
        policePhone: '+62 812-1719-8527',
        picName: 'MUSTOFA',
        picPhone: '+62 877-4534-4688',
        landArea: 3.50,
        landCategory: 'POKTAN BINAAN POLRI',
        status: 'PROSES PANEN',
        statusColor: '#FF9800',
      ),

      // --- GRUP 3: PLAKARAN / PLAKARAN (Item B - Duplicate data visual check) ---
      LandHistoryItemModel(
        id: '4',
        regionGroup: 'KAB. BANGKALAN KEC. AROSBAYA DESA PLAKARAN',
        subRegionGroup: 'DUSUN PLAKARAN',
        policeName: 'RUDI HARTONO',
        policePhone: '+62 812-1719-8527',
        picName: 'MUSTOFA',
        picPhone: '+62 877-4534-4688',
        landArea: 3.50,
        landCategory: 'POKTAN BINAAN POLRI',
        status: 'PROSES PANEN',
        statusColor: '#FF9800',
      ),
      
      // Data dummy tambahan untuk tes scroll
      LandHistoryItemModel(
        id: '5',
        regionGroup: 'KAB. BANGKALAN KEC. AROSBAYA DESA PLAKARAN',
        subRegionGroup: 'DUSUN PLAKARAN',
        policeName: 'RUDI HARTONO',
        policePhone: '+62 812-1719-8527',
        picName: 'MUSTOFA',
        picPhone: '+62 877-4534-4688',
        landArea: 3.50,
        landCategory: 'POKTAN BINAAN POLRI',
        status: 'PROSES PANEN',
        statusColor: '#FF9800',
      ),
    ];
  }
}