class CommodityModel {
  final String id;
  final String categoryId;
  final String name;
  final bool isSelected;

  const CommodityModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.isSelected = false,
  });

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

  // --- TAMBAHKAN INI ---
  factory CommodityModel.fromJson(Map<String, dynamic> json) {
    return CommodityModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      name: json['name'] ?? '',
      isSelected: json['isSelected'] ?? false,
    );
  }
}