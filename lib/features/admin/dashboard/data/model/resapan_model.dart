class ResapanItem {
  final String label;
  final int value;

  ResapanItem({
    required this.label, 
    required this.value
  });

  factory ResapanItem.fromJson(Map<String, dynamic> json) {
    return ResapanItem(
      label: json['label'] ?? "-",
      value: (json['value'] as num?)?.toInt() ?? 0,
    );
  }
}

class ResapanModel {
  final String year;
  final int total;
  final List<ResapanItem> items;

  ResapanModel({
    required this.year,
    required this.total,
    required this.items,
  });

  factory ResapanModel.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<ResapanItem> itemsList = list.map((i) => ResapanItem.fromJson(i)).toList();
    
    return ResapanModel(
      year: json['year'] ?? "2026",
      total: (json['total'] as num?)?.toInt() ?? 0,
      items: itemsList,
    );
  }
}