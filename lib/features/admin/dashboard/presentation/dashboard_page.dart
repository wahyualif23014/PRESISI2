import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORT PROVIDER ---
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/providers/dashboard_provider.dart';

import 'widgets/dashboard_header.dart';
import 'widgets/ringkasan_aset.dart';
import 'widgets/carousel.dart';
import 'widgets/total_summary_section.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/data_kwartal.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/distribution_card.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/grafik_pertumbuhan.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/resapan_card.dart';

import '../data/repo/harvest_repository.dart';
import '../data/repo/kwartal_repo.dart';
import '../data/repo/summary_repository.dart';
import '../data/repo/ringkasan_area_repository.dart';
import '../data/repo/distribution_repository.dart';
import '../data/repo/resapan_repository.dart';
import '../data/model/carousel_item_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final harvestData = HarvestRepository().getHarvestData();
  final summaryData = SummaryRepository().getSummaryData();
  final quarterlyData = QuarterlyRepository().getQuarterlyData();
  final lahanDataList = RingkasanAreaRepository().getRingkasanList();
  final resapanData = ResapanRepository().getResapanData();
  final distributionRepo = DistributionRepository();

  late final totalTitikData = distributionRepo.getTotalTitikLahan();
  late final pengelolaData = distributionRepo.getPengelolaLahan();

  @override
  void initState() {
    super.initState();
    // FETCH DATA DARI PROVIDER SAAT HALAMAN DIBUKA
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      if (provider.data == null) {
        provider.fetchDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. AMBIL DATA USER DARI AUTH PROVIDER
    final UserModel? user = context.select<AuthProvider, UserModel?>(
      (auth) => auth.user,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // 2. GUNAKAN CONSUMER DASHBOARD PROVIDER
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProv, child) {
          // Loading State Global
          if (dashboardProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error State
          if (dashboardProv.errorMessage != null) {
            return Center(child: Text("Error: ${dashboardProv.errorMessage}"));
          }



          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A. HEADER SECTION (Dinamis dari AuthProvider)
                DashboardHeader(
                  userName: user?.namaLengkap ?? "Pengguna",
                  userRole: user?.roleDisplay ?? "User",
                ),

                const SizedBox(height: 20),

                // B. CAROUSEL SECTION
                SizedBox(
                  height: 240,
                  child: PromoCarousel(items: dummyCarouselData),
                ),

                const SizedBox(height: 15),

                _buildSectionTitle("Ringkasan Area Lahan"),
                const SizedBox(height: 10),

                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 768;
                    final totalLahan = lahanDataList[0];
                    final potensiLahan = lahanDataList[1];
                    final panenLahan = lahanDataList[2];

                    if (isMobile) {
                      return Column(
                        children: [
                          LahanStatCard(
                            data: totalLahan,
                            backgroundColor: totalLahan.backgroundColor,
                            layoutType: CardLayoutType.list,
                          ),
                          const SizedBox(height: 10),
                          LahanStatCard(
                            data: potensiLahan,
                            backgroundColor: potensiLahan.backgroundColor,
                            layoutType: CardLayoutType.grid,
                          ),
                          const SizedBox(height: 10),
                          LahanStatCard(
                            data: panenLahan,
                            backgroundColor: panenLahan.backgroundColor,
                            layoutType: CardLayoutType.grid,
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: LahanStatCard(
                              data: totalLahan,
                              backgroundColor: totalLahan.backgroundColor,
                              layoutType: CardLayoutType.list,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                LahanStatCard(
                                  data: potensiLahan,
                                  backgroundColor: potensiLahan.backgroundColor,
                                  layoutType: CardLayoutType.grid,
                                ),
                                const SizedBox(height: 10),
                                LahanStatCard(
                                  data: panenLahan,
                                  backgroundColor: panenLahan.backgroundColor,
                                  layoutType: CardLayoutType.grid,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 8),

                // D. CHART SECTION
                _buildSectionTitle("Analisis Hasil Panen"),
                const SizedBox(height: 12),
                GrafikChartCard(data: harvestData),

                const SizedBox(height: 10),

                // E. DATA KWARTAL
                _buildSectionTitle("Data Kwartal"),
                const SizedBox(height: 20),
                QuarterlyStatsSection(items: quarterlyData),

                const SizedBox(height: 10),

                // F. SUMMARY
                _buildSectionTitle("Ringkasan Keseluruhan"),
                const SizedBox(height: 12),
                TotalSummarySection(items: summaryData),
                const SizedBox(height: 20),

                _buildSectionTitle("Peta Penyebaran Potensi Lahan"),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: DistributionCard(data: totalTitikData)),
                    const SizedBox(width: 16),
                    Expanded(child: DistributionCard(data: pengelolaData)),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionTitle("Total Resapan Per Tahun"),
                const SizedBox(height: 12),
                ResapanCard(data: resapanData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      padding: const EdgeInsets.only(left: 12.0),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Colors.black, width: 4.0)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
