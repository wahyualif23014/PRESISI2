import 'package:flutter/material.dart';
import '/features/admin/dashboard/presentation/widgets/total_summary_section.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';
import '../../../../auth/provider/auth_provider.dart';
import '../data/model/carousel_item_model.dart';

import 'widgets/dashboard_header.dart';
import 'widgets/lahan_stat_card.dart'; // Widget baru
import 'widgets/Total_Hasil_Panen.dart';
import 'widgets/carousel.dart';
import 'widgets/quarterly_stats_section.dart';
import 'widgets/distribution_card.dart';
import 'widgets/resapan_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.user?.nama ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<DashboardProvider>().refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Consumer<DashboardProvider>(
            builder: (context, dashboard, child) {
              if (dashboard.isLoading) {
                return const SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (dashboard.errorMessage != null) {
                return SizedBox(
                  height: 400,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text("Gagal memuat data: ${dashboard.errorMessage}"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => dashboard.fetchDashboardData(),
                          child: const Text("Coba Lagi"),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final data = dashboard.data;
              if (data == null) {
                return const Center(child: Text("Data tidak tersedia"));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. HEADER SECTION
                  DashboardHeader(userName: userName, data: dashboard.data!),

                  const SizedBox(height: 30),

                  // B. CAROUSEL SECTION
                  SizedBox(
                    height: 240,
                    child: PromoCarousel(
                      items: dummyCarouselData,
                      onTap: (item) {
                        print("Banner diklik: ${item.title}");
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // C. STATISTICS SECTION (Updated Layout)
                  _buildSectionTitle("Ringkasan Area Lahan"),
                  const SizedBox(height: 12),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 768;

                      if (isMobile) {
                        // TAMPILAN MOBILE (Vertical)
                        return Column(
                          children: [
                            LahanStatCard(
                              title: "Total Lahan Tahun 2026",
                              data: data.totalLuasTanam,
                              backgroundColor: const Color(0xFF315FA4),
                              layoutType: CardLayoutType.list,
                            ),
                            const SizedBox(height: 16),
                            LahanStatCard(
                              title: "Potensi Lahan Tanam Tahun 2026",
                              data: data.potensiLahan,
                              backgroundColor: const Color(0xFF1BB555),
                              layoutType: CardLayoutType.grid,
                            ),
                            const SizedBox(height: 16),
                            LahanStatCard(
                              title: "Total Lahan Panen Tahun 2026",
                              data: data.totalLuasPanen,
                              backgroundColor: const Color(0xFFD42525),
                              layoutType: CardLayoutType.grid,
                            ),
                          ],
                        );
                      } else {
                        // TAMPILAN TABLET/WEB (Grid Layout)
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: LahanStatCard(
                                title: "Total Lahan Tanam Tahun 2026",
                                data: data.totalLuasTanam,
                                backgroundColor: const Color(0xFF315FA4),
                                layoutType: CardLayoutType.list,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  LahanStatCard(
                                    title: "Potensi Lahan Tahun 2026",
                                    data: data.potensiLahan,
                                    backgroundColor: const Color(0xFF05CD99),
                                    layoutType: CardLayoutType.grid,
                                  ),
                                  const SizedBox(height: 16),
                                  LahanStatCard(
                                    title: "Total Lahan Panen Tahun 2026",
                                    data: data.totalLuasPanen,
                                    backgroundColor: const Color(0xFF05CD99),
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

                  // D. CHART SECTION
                  _buildSectionTitle("Analisis Hasil Panen"),
                  const SizedBox(height: 12),

                  HarvestChartCard(totalPanen: data.totalHasilPanen),
                  const SizedBox(height: 32),

                  _buildSectionTitle("Data Kwartal"),

                  const SizedBox(height: 20),
                  QuarterlyStatsSection(items: dashboard.data!.quarterlyData),

                  const SizedBox(height: 32),

                  _buildSectionTitle("Ringkasan Keseluruhan"),
                  const SizedBox(height: 12),

                  TotalSummarySection(items: dashboard.data!.summaryData),
                  const SizedBox(height: 32),

                  _buildSectionTitle("Peta Penyebaran Potensi Lahan"),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      // --- KARTU 1: TOTAL TITIK LAHAN (Biru & Ungu) ---
                      Expanded(
                        child: DistributionCard(
                          title:
                              data
                                  .totalTitikLahan
                                  .label, // Ambil dari Model: "Total Titik Lahan"
                          totalValue:
                              data
                                  .totalTitikLahan
                                  .total, // Ambil dari Model: 90
                          chartColors: const [
                            Color(0xFF3B82F6), // Biru
                            Color(0xFFC084FC), // Ungu
                          ],

                          proportions: const [0.5, 0.5],
                        ),
                      ),

                      const SizedBox(width: 16), // Jarak antar kartu
                      Expanded(
                        child: DistributionCard(
                          title:
                              data
                                  .pengelolaLahan
                                  .label, // "Pengelolah Lahan Polsek"
                          totalValue: data.pengelolaLahan.total, // 203
                          chartColors: const [
                            Color(0xFFEF4444), // Merah
                            Color(0xFF22C55E), // Hijau
                          ],

                          proportions: const [0.15, 0.85],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle("Total Resapan Per Tahun"),
                  const SizedBox(height: 12),
                  ResapanCard(data: data.resapanData),
                ],
              );
            },
          ),
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
