import '../models/commodity_category_model.dart';
import '../models/commodity_model.dart';

class CommodityRepository {
  
  /// DATA KATEGORI (Simulasi Backend Get All Categories)
  /// Nanti ganti return ini dengan: await api.get('/categories');
  static List<CommodityCategoryModel> getCategoryData() {
    return [
      const CommodityCategoryModel(
        id: '1',
        title: 'HORTIKULTURA',
        imageAsset: 'assets/images/hortikultura.jpg',
        tags: ['KUBIS', 'TIMUN', 'TOMAT'],
        description: 'HORTIKULTURA ADALAH CABANG PERTANIAN YANG FOKUS PADA BUDIDAYA INTENSIF TANAMAN KEBUN.',
      ),
    ];
  }


  static List<CommodityModel> getCommoditiesByCategory(String categoryId) {
    if (categoryId == '1') {
      return [
        const CommodityModel(id: '101', categoryId: '1', name: 'BAWANG MERAH'),
      ];
    }
    
    return [];
  }
}