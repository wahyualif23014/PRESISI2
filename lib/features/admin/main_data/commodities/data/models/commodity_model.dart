class CommodityModel {
  final String id;          // Unique ID item
  final String categoryId;  // PENTING: Penghubung ke CommodityCategoryModel.id
  final String name;        // Contoh: "BAWANG MERAH"
  final bool isSelected;    // Untuk fitur Checkbox UI

  const CommodityModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.isSelected = false, // Default tidak tercentang
  });

  // Wajib ada untuk update status checkbox (State Management)
  CommodityModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    bool? isSelected,
  }) {
    return CommodityModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}