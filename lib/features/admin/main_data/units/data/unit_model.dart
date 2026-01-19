class UnitModel {
  final String title;
  final String subtitle;
  final String count;
  final bool isPolres; // true jika Polres, false jika Polsek

  UnitModel({
    required this.title,
    required this.subtitle,
    required this.count,
    this.isPolres = false,
  });
}