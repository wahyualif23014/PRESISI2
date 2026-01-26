class CommodityCategoryModel {
  final String id;
  final String title;       // Contoh: "HORTIKULTURA"
  final String description; // Contoh: "Hortikultura adalah cabang pertanian..."
  final String imageAsset;  // Path gambar asset
  final List<String> tags;  // Contoh: ["KUBIS", "TIMUN", "TOMAT"]

  CommodityCategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.tags,
  });
}