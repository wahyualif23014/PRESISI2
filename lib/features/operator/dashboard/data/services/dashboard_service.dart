// lib/features/operator/dashboard/data/services/operator_dashboard_service.dart

import 'dart:async';
import '../model/operator_dashboard_model.dart';

// lib/features/operator/dashboard/data/services/operator_dashboard_service.dart

import 'dart:async';
import '../model/operator_dashboard_model.dart';

class OperatorDashboardService {
  Future<OperatorDashboardModel> getOperatorData() async {
    try {
      // Simulasi delay network
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock Data: Nantinya ganti dengan panggil API/Repository asli
      return OperatorDashboardModel(
        totalLahan: 3,
        tugasPending: 2,
        daftarLahan: [
          LahanOperator(nama: "Blok Ketela A1", status: "Aktif", lokasi: "Sektor Utara"),
          LahanOperator(nama: "Lahan Jagung B2", status: "Pending", lokasi: "Sektor Selatan"),
          LahanOperator(nama: "Area Padi C3", status: "Aktif", lokasi: "Sektor Barat"),
        ],
      );
    } catch (e) {
      throw Exception('Gagal mengambil data operator: $e');
    }
  }
}