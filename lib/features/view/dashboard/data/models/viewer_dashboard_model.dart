// lib/features/view/dashboard/data/models/viewer_dashboard_model.dart

class ViewerDashboardModel {
  final double totalProduksi;
  final int totalTitikLahan;
  final double persentaseTarget;
  final List<SebaranData> sebaranWilayah;

  ViewerDashboardModel({
    required this.totalProduksi,
    required this.totalTitikLahan,
    required this.persentaseTarget,
    required this.sebaranWilayah,
  });

  factory ViewerDashboardModel.empty() {
    return ViewerDashboardModel(
      totalProduksi: 0.0,
      totalTitikLahan: 0,
      persentaseTarget: 0.0,
      sebaranWilayah: [],
    );
  }
}

class SebaranData {
  final String wilayah;
  final double nilai;

  SebaranData(this.wilayah, this.nilai);
}
