class CommodityModel {
  final String id;
  final String categoryId; // PENTING: Untuk menghubungkan dengan Kategori Induk
  final String name;       // Contoh: "BAWANG MERAH"
  bool isSelected;         // Untuk Checkbox

  CommodityModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.isSelected = false,
  });
}