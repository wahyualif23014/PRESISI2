import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/repo/resapan_repository.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/data_kwartal.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/distribution_card.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/grafik_pertumbuhan.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/resapan_card.dart';

// --- IMPORT REPOSITORY (Untuk Data Dummy) ---
import '../data/repo/harvest_repository.dart';
import '../data/repo/kwartal_repo.dart';
import '../data/repo/summary_repository.dart';
import '../data/repo/ringkasan_area_repository.dart';
import '../data/repo/distribution_repository.dart';

// --- IMPORT MODELS ---
import '../data/model/carousel_item_model.dart';
import '../data/model/kwartal_item_model.dart';
import '../data/model/ringkasan_area_model.dart';

// --- IMPORT WIDGETS ---
import 'widgets/dashboard_header.dart';
import 'widgets/ringkasan_aset.dart';
import 'widgets/carousel.dart';
import 'widgets/total_summary_section.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Inisialisasi Data Dummy Langsung di sini
  final harvestData = HarvestRepository().getHarvestData();
  final summaryData = SummaryRepository().getSummaryData();
  final List<QuarterlyItem> quarterlyData =
      QuarterlyRepository().getQuarterlyData();
  final List<RingkasanAreaModel> lahanDataList =
      RingkasanAreaRepository().getRingkasanList();
  final resapanData = ResapanRepository().getResapanData();
  final distributionRepo = DistributionRepository();
  late final totalTitikData = distributionRepo.getTotalTitikLahan();
  late final pengelolaData = distributionRepo.getPengelolaLahan();

  @override
  Widget build(BuildContext context) {
    const userName = "Admin User";
    const userRole = "Polda Jatim";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A. HEADER SECTION
            const DashboardHeader(userName: userName, userRole: userRole),

            const SizedBox(height: 20),

            // B. CAROUSEL SECTION
            SizedBox(
              height: 240,
              child: PromoCarousel(items: dummyCarouselData),
            ),

            const SizedBox(height: 20),

            // C. STATISTICS SECTION (LAHAN)
            _buildSectionTitle("Ringkasan Area Lahan"),
            const SizedBox(height: 12),

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

            const SizedBox(height: 32),

            // D. CHART SECTION (GRAFIK PANEN)
            _buildSectionTitle("Analisis Hasil Panen"),
            const SizedBox(height: 12),
            GrafikChartCard(data: harvestData),

            const SizedBox(height: 32),

            // E. DATA KWARTAL
            _buildSectionTitle("Data Kwartal"),
            const SizedBox(height: 20),
            QuarterlyStatsSection(items: quarterlyData),

            const SizedBox(height: 32),

            // F. SUMMARY (RINGKASAN)
            _buildSectionTitle("Ringkasan Keseluruhan"),
            const SizedBox(height: 12),
            TotalSummarySection(items: summaryData),
            const SizedBox(height: 20),

            _buildSectionTitle("Peta Penyebaran Potensi Lahan"),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: DistributionCard(
                    data: totalTitikData, // Panggil sesuai keinginan Anda
                  ),
                ),

                const SizedBox(width: 16), // Jarak antar kartu
                Expanded(child: DistributionCard(data: pengelolaData)),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle("Total Resapan Per Tahun"),
            const SizedBox(height: 12),
            ResapanCard(data: resapanData),
          ],
        ),
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
