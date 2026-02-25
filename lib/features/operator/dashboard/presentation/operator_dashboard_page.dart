import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:KETAHANANPANGAN/features/operator/dashboard/providers/dashboard_provider.dart';

// --- IMPORT WIDGETS ADMIN ---
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/ringkasan_aset.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/carousel.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/total_summary_section.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/data_kwartal.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/distribution_card.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/grafik_pertumbuhan.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/resapan_card.dart';

// --- IMPORT MODEL & REPO ADMIN ---
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/repo/harvest_repository.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/repo/kwartal_repo.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/repo/summary_repository.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/repo/ringkasan_area_repository.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/repo/distribution_repository.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/repo/resapan_repository.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/carousel_item_model.dart';

class OperatorDashboardPage extends StatefulWidget {
  const OperatorDashboardPage({super.key});

  @override
  State<OperatorDashboardPage> createState() => _OperatorDashboardPageState();
}

class _OperatorDashboardPageState extends State<OperatorDashboardPage> {
  final harvestData = HarvestRepository().getHarvestData();
  final summaryData = SummaryRepository().getSummaryData();
  final quarterlyData = QuarterlyRepository().getQuarterlyData();
  final lahanDataList = RingkasanAreaRepository().getRingkasanList();
  final resapanData = ResapanRepository().getResapanData();
  final distributionRepo = DistributionRepository();

  late final totalTitikData = distributionRepo.getTotalTitikLahan();
  late final pengelolaData = distributionRepo.getPengelolaLahan();

  // Data banner disamakan dengan Admin menggunakan ID wajib
  final List<CarouselItemModel> bannerItems = [
    CarouselItemModel(
      id: '1',
      imageUrl:
          'https://images.unsplash.com/photo-1538115081112-32c7d8401807?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8cG9scml8ZW58MHx8MHx8fDA%3D', // Gambar sawah/pertanian
      title: 'Panen Raya',
      subtitle: 'Hasil melimpah musim ini',
    ),
    CarouselItemModel(
      id: '2',
      imageUrl:
          'https://www.suaramuhammadiyah.id/storage/posts/image/Polda_Jatim_dan_UMM-20241004134811.jpeg', // Gambar ladang hijau
      title: 'Lahan Subur',
      subtitle: 'Optimalkan potensi tanah',
    ),
    CarouselItemModel(
      id: '3',
      imageUrl:
          'https://memorandum.disway.id/upload/740da7d86f13e02e4c17e6a89756364f.jpeg', // Gambar teknologi tani
      title: 'Teknologi Tani',
      subtitle: 'Modernisasi alat pertanian',
    ),
    CarouselItemModel(
      id: '4',
      imageUrl:
          'https://cdn.antaranews.com/cache/1200x800/2023/08/01/IMG-20230801-WA0082_1.jpg', // Gambar teknologi tani
      title: 'SDM Polda',
      subtitle: 'Melakukan pengawasan dalam genggaman',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OperatorDashboardProvider>().fetchOperatorData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = context.select<AuthProvider, UserModel?>(
      (auth) => auth.user,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<OperatorDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchOperatorData(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              children: [
                // A. Header Section
                DashboardHeader(
                  userName: user?.namaLengkap ?? "Operator",
                  userRole: user?.roleDisplay ?? "Operator Lahan",
                ),
                const SizedBox(height: 20),

                // B. Banner Section (Sama dengan Admin)
                SizedBox(height: 240, child: PromoCarousel(items: bannerItems)),

                const SizedBox(height: 15),

                // C. Ringkasan Lahan Section
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
                        mainAxisSize: MainAxisSize.min,
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
                              mainAxisSize: MainAxisSize.min,
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

                // D. Chart & Stats Section
                _buildSectionTitle("Analisis Hasil Panen"),
                const SizedBox(height: 12),
                GrafikChartCard(data: harvestData),

                const SizedBox(height: 10),
                _buildSectionTitle("Data Kwartal"),
                const SizedBox(height: 20),
                QuarterlyStatsSection(items: quarterlyData),

                const SizedBox(height: 10),
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
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
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
