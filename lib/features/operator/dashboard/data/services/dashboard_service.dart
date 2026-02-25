// lib/features/operator/dashboard/data/services/dashboard_service.dart

import '../model/operator_dashboard_model.dart';

class DashboardService {
  Future<OperatorDashboardModel> getOperatorDashboardData() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi API
    return OperatorDashboardModel(
      totalLahan: 10,
      tugasPending: 2,
      daftarLahan: [],
    );
  }
}
