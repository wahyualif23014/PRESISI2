// lib/features/view/dashboard/data/services/dashboard_service.dart

import '../models/viewer_dashboard_model.dart';

class ViewerDashboardService {
  Future<ViewerDashboardModel> getViewerStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      return ViewerDashboardModel(
        totalProduksi: 1250.5,
        totalTitikLahan: 45,
        persentaseTarget: 85.5,
        sebaranWilayah: [
          SebaranData("Utara", 400),
          SebaranData("Selatan", 350),
          SebaranData("Barat", 500),
        ],
      );
    } catch (e) {
      throw Exception('Gagal memuat data monitoring: $e');
    }
  }
}
