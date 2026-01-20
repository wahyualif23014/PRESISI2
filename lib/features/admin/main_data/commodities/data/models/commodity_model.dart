class CommodityModel {
  final String id;
  final String type; // Pengelompokan (Contoh: TANAMAN KEHUTANAN)
  final String name; // Nama Komoditi (Contoh: AKASIA)
  bool isSelected;   // Status Checkbox

  CommodityModel({
    required this.id,
    required this.type,
    required this.name,
    this.isSelected = false,
  });
}