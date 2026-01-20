import './commodity_model.dart';

class CommodityRepository {
  static List<CommodityModel> getDummyData() {
    return [
      // KELOMPOK 1: TANAMAN KEHUTANAN
      CommodityModel(id: '1', type: 'TANAMAN KEHUTANAN', name: 'AKASIA'),
      CommodityModel(id: '2', type: 'TANAMAN KEHUTANAN', name: 'JATI'),
      CommodityModel(id: '3', type: 'TANAMAN KEHUTANAN', name: 'SENGON'),
      CommodityModel(id: '4', type: 'TANAMAN KEHUTANAN', name: 'MAHONI'),

      // KELOMPOK 2: TANAMAN PANGAN
      CommodityModel(id: '5', type: 'TANAMAN PANGAN', name: 'PADI'),
      CommodityModel(id: '6', type: 'TANAMAN PANGAN', name: 'JAGUNG'),
      CommodityModel(id: '7', type: 'TANAMAN PANGAN', name: 'KEDELAI'),

      // KELOMPOK 3: TANAMAN PERKEBUNAN
      CommodityModel(id: '8', type: 'TANAMAN PERKEBUNAN', name: 'KELAPA SAWIT'),
      CommodityModel(id: '9', type: 'TANAMAN PERKEBUNAN', name: 'KARET'),
      CommodityModel(id: '10', type: 'TANAMAN PERKEBUNAN', name: 'KOPI'),
      CommodityModel(id: '11', type: 'TANAMAN PERKEBUNAN', name: 'KAKAO'),
    ];
  }
}