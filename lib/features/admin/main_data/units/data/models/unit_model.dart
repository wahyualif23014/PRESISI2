// Lokasi: lib/features/admin/main_data/units/data/unit_model.dart

class UnitModel {
  final String title;
  final String subtitle;
  final String count;
  final bool isPolres; 

  UnitModel({
    required this.title,
    required this.subtitle,
    required this.count,
    this.isPolres = false,
  });
}

// --- TAMBAHAN BARU ---
class UnitRegion {
  final UnitModel polres;        
  final List<UnitModel> polseks; // Data Anak (List Polsek)
  bool isExpanded;               

  UnitRegion({
    required this.polres,
    required this.polseks,
    this.isExpanded = false, // Default tertutup
  });
}