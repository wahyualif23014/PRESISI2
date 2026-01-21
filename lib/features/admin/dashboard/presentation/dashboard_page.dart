import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/dashboard/presentation/widgets/data_kwartal.dart';
import 'package:sdmapp/features/admin/dashboard/presentation/widgets/grafik_pertumbuhan.dart';

// --- IMPORT REPOSITORY (Untuk Data Dummy) ---
import '../data/repo/harvest_repository.dart';
import '../data/repo/kwartal_repo.dart';
import '../data/repo/summary_repository.dart';
import '../data/repo/ringkasan_area_repository.dart'; // Pastikan Repo Lahan diimport

// --- IMPORT MODELS ---
import '../data/model/carousel_item_model.dart';
import '../data/model/kwartal_item_model.dart';
import '../data/model/ringkasan_area_model.dart';

// --- IMPORT WIDGETS ---
import 'widgets/dashboard_header.dart';
import 'widgets/lahan_stat_card.dart';
import 'widgets/carousel.dart';
import 'widgets/total_summary_section.dart';
// import 'widgets/distribution_card.dart'; // Jika belum siap, komen dulu
// import 'widgets/resapan_card.dart';      // Jika belum siap, komen dulu

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Inisialisasi Data Dummy Langsung di sini
  late final harvestData = HarvestRepository().getHarvestData();
  late final summaryData = SummaryRepository().getSummaryData();
  late final List<QuarterlyItem> quarterlyData =
      QuarterlyRepository().getQuarterlyData();

  // Ambil Data Lahan dari Repo Lahan (RingkasanAreaRepository)
  late final List<RingkasanAreaModel> lahanDataList =
      RingkasanAreaRepository().getRingkasanList();

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
            const DashboardHeader(
              userName: userName,
              userRole: userRole,
            ),

            const SizedBox(height: 30),

            // B. CAROUSEL SECTION
            SizedBox(
              height: 240,
              child: PromoCarousel(items: dummyCarouselData),
            ),

            const SizedBox(height: 24),

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
                      const SizedBox(height: 16),
                      LahanStatCard(
                        data: potensiLahan,
                        backgroundColor: potensiLahan.backgroundColor,
                        layoutType: CardLayoutType.grid,
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            LahanStatCard(
                              data: potensiLahan,
                              backgroundColor: potensiLahan.backgroundColor,
                              layoutType: CardLayoutType.grid,
                            ),
                            const SizedBox(height: 16),
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

            const SizedBox(height: 32),

            // G. WIDGET LAINNYA (Opsional, buka komen jika widget siap & repo ada)
            
            _buildSectionTitle("Peta Penyebaran Potensi Lahan"),
            const SizedBox(height: 50),
            // ... DistributionCard logic ...
            
            const SizedBox(height: 32),
            _buildSectionTitle("Total Resapan Per Tahun"),
            const SizedBox(height: 12),
            // ResapanCard(data: ...),
            
            
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
        letterSpacing: 1.0,
      ),
    );
  }
}
