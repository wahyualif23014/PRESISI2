import '../models/commodity_category_model.dart';
import '../models/commodity_model.dart';

class CommodityRepository {
  static List<CommodityCategoryModel> getCategoryData() {
    return [
      const CommodityCategoryModel(
        id: '1',
        title: 'HORTIKULTURA',
        imageAsset:
            'assets/images/hortikultura.jpg', // Ini biarkan saja (dummy)
        tags: ['KUBIS', 'TIMUN', 'TOMAT'],
        // HAPUS BARIS DESCRIPTION DI BAWAH INI
        // description: 'HORTIKULTURA ADALAH ...',
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
