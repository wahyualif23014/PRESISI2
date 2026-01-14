class UnitKerja {
  final String id;
  final String nama;

  const UnitKerja({
    required this.id,
    required this.nama,
  });

  factory UnitKerja.fromJson(Map<String, dynamic> json) {
    return UnitKerja(
      id: json['id'],
      nama: json['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}
