// lib/features/operator/dashboard/data/model/operator_dashboard_model.dart

class OperatorDashboardModel {
  final int totalLahan;
  final int tugasPending;
  final List<LahanOperator> daftarLahan;

  OperatorDashboardModel({
    required this.totalLahan,
    required this.tugasPending,
    required this.daftarLahan,
  });

  // Mencegah error null saat inisialisasi awal
  factory OperatorDashboardModel.empty() {
    return OperatorDashboardModel(
      totalLahan: 0,
      tugasPending: 0,
      daftarLahan: [],
    );
  }
}

class LahanOperator {
  final String nama;
  final String status; // 'Aktif' atau 'Pending'
  final String lokasi;

  LahanOperator({
    required this.nama, 
    required this.status, 
    required this.lokasi
  });
}