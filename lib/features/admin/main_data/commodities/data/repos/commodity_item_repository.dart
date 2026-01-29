import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/data/models/commodity_model.dart';

class CommodityItemRepository {
  // Database Dummy Utama (Ceritanya ini database backend)
  static final List<CommodityModel> _allMockItems = [
    CommodityModel(id: 'h1', categoryId: '1', name: 'BAWANG MERAH'),
    CommodityModel(id: 'h2', categoryId: '1', name: 'BAWANG PUTIH'),
    CommodityModel(id: 'h3', categoryId: '1', name: 'CABAI MERAH'),
    CommodityModel(id: 'h4', categoryId: '1', name: 'CABAI RAWIT'),
    CommodityModel(id: 'h5', categoryId: '1', name: 'KENTANG'),
    CommodityModel(id: 'h6', categoryId: '1', name: 'KUBIS'),
    CommodityModel(id: 'h7', categoryId: '1', name: 'TERONG'),
    CommodityModel(id: 'h8', categoryId: '1', name: 'TIMUN'),
    CommodityModel(id: 'h9', categoryId: '1', name: 'TOMAT'),
    CommodityModel(id: 'h10', categoryId: '1', name: 'WORTEL'),

    // --- DATA KATEGORI 2: PERKEBUNAN ---
    CommodityModel(id: 'p1', categoryId: '2', name: 'KELAPA SAWIT'),
    CommodityModel(id: 'p2', categoryId: '2', name: 'KARET'),
    CommodityModel(id: 'p3', categoryId: '2', name: 'KAKAO (COKLAT)'),
    CommodityModel(id: 'p4', categoryId: '2', name: 'TEBU'),
    CommodityModel(id: 'p5', categoryId: '2', name: 'KOPI'),
    CommodityModel(id: 'p6', categoryId: '2', name: 'LADA'),

    // --- DATA KATEGORI 3: TANAMAN BUAH ---
    CommodityModel(id: 'b1', categoryId: '3', name: 'MANGGA'),
    CommodityModel(id: 'b2', categoryId: '3', name: 'DURIAN'),
    CommodityModel(id: 'b3', categoryId: '3', name: 'ALPUKAT'),
    CommodityModel(id: 'b4', categoryId: '3', name: 'JERUK'),
    CommodityModel(id: 'b5', categoryId: '3', name: 'MANGGIS'),

    // --- DATA KATEGORI 4: TANAMAN KEHUTANAN ---
    CommodityModel(id: 'k1', categoryId: '4', name: 'JATI'),
    CommodityModel(id: 'k2', categoryId: '4', name: 'MAHONI'),
    CommodityModel(id: 'k3', categoryId: '4', name: 'SENGON'),
    CommodityModel(id: 'k4', categoryId: '4', name: 'AKASIA'),
    CommodityModel(id: 'k5', categoryId: '4', name: 'BAMBU'),
  ];

  static Future<List<CommodityModel>> getItemsByCategoryId(
    String categoryId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _allMockItems
        .where((item) => item.categoryId == categoryId)
        .toList();
  }
}
