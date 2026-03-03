import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORT PROVIDER ---
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/providers/dashboard_provider.dart';

// --- IMPORT WIDGETS & MODELS ---
import 'widgets/dashboard_header.dart';
import 'widgets/ringkasan_aset.dart'; // Berisi LahanStatCard
import 'widgets/carousel.dart';
import 'widgets/total_summary_section.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/data_kwartal.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/distribution_card.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/grafik_pertumbuhan.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/resapan_card.dart';
import '../data/model/carousel_item_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Fetch data dinamis dari backend saat halaman diinisialisasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data user login secara reaktif
    final UserModel? user = context.select<AuthProvider, UserModel?>(
      (auth) => auth.user,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProv, child) {
          // 1. Loading State
          if (dashboardProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (dashboardProv.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Error: ${dashboardProv.errorMessage}"),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => dashboardProv.fetchDashboard(),
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            );
          }

          // Ambil data dashboard hasil parsing dari backend Go
          final data = dashboardProv.dashboardData;
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () => dashboardProv.fetchDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. HEADER SECTION
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

                  const SizedBox(height: 25),

                  // C. SECTION TOTAL LAHAN (Sesuai Desain Beranda.jpg)
                  _buildSectionTitle("Total Lahan"),
                  const SizedBox(height: 12),
                  
                  if (data.lahanData.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kiri: Kartu Utama (Index 0) - Layout LIST
                        Expanded(
                          flex: 5,
                          child: LahanStatCard(
                            data: data.lahanData[0],
                            layoutType: CardLayoutType.list,
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Kanan: Kartu Pendamping (Index 1 & 2) - Layout GRID
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              if (data.lahanData.length > 1)
                                LahanStatCard(
                                  data: data.lahanData[1],
                                  layoutType: CardLayoutType.grid,
                                ),
                              const SizedBox(height: 12),
                              if (data.lahanData.length > 2)
                                LahanStatCard(
                                  data: data.lahanData[2],
                                  layoutType: CardLayoutType.grid,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // D. ANALISIS HASIL PANEN (Grafik Pertumbuhan)
                  _buildSectionTitle("Grafik Pertumbuhan"),
                  const SizedBox(height: 12),
                  if (data.harvestData != null)
                    GrafikChartCard(data: data.harvestData!),

                  const SizedBox(height: 24),

                  // E. DATA KWARTAL
                  _buildSectionTitle("Data Kwartal"),
                  const SizedBox(height: 12),
                  if (data.quarterlyData.isNotEmpty)
                    QuarterlyStatsSection(items: data.quarterlyData),

                  const SizedBox(height: 24),

                  // F. RINGKASAN KESELURUHAN (Summary Cards Berhasil/Gagal)
                  _buildSectionTitle("Total Keseluruhan"),
                  const SizedBox(height: 12),
                  TotalSummarySection(items: data.summaryData),

                  const SizedBox(height: 24),

                  // G. PETA PENYEBARAN
                  _buildSectionTitle("Peta Penyebaran Potensi Lahan"),
                  const SizedBox(height: 12),
                  if (data.distributionData.isNotEmpty)
                    Row(
                      children: [
                        Expanded(child: DistributionCard(data: data.distributionData[0])),
                        if (data.distributionData.length > 1) ...[
                          const SizedBox(width: 16),
                          Expanded(child: DistributionCard(data: data.distributionData[1])),
                        ],
                      ],
                    ),

                  const SizedBox(height: 32),

                  // H. TOTAL RESAPAN
                  if (data.resapanData != null) ...[
                    _buildSectionTitle("Total Resapan Per Tahun ${data.resapanData!.year}"),
                    const SizedBox(height: 12),
                    ResapanCard(data: data.resapanData!),
                  ],
                  const SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1E293B), // Slate 800
      ),
    );
  }
}