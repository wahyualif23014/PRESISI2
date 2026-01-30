class CommodityCategoryModel {
  final String id;          // Primary Key (Contoh: "1")
  final String title;       // Contoh: "HORTIKULTURA"
  final String description; 
  final String imageAsset;  
  final List<String> tags;  // Hanya untuk tampilan label di Card depan

  const CommodityCategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.tags,
  });
}