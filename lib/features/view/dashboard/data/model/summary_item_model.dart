
// Enum untuk menentukan Tipe Icon & Warna (agar tidak pakai String hardcode)
enum SummaryType {
  success,  // Berhasil -> Icon Traktor/Agriculture
  failed,   // Gagal -> Icon Warning
  plant,    // Tanam -> Icon Eco/Leaf
  process,  // Proses -> Icon Hourglass
}

class SummaryItemModel {
  final String label;    // Contoh: "Berhasil", "Gagal"
  final double value;    // Contoh: 90
  final String unit;     // Contoh: "HA"
  final SummaryType type; // Enum tipe untuk menentukan Icon

  const SummaryItemModel({
    required this.label,
    required this.value,
    required this.unit,
    required this.type,
  });
}