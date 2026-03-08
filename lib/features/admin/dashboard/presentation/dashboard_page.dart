import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/potensi_map_widget.dart'
    show PotensiMapSection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/providers/dashboard_provider.dart';

import 'widgets/dashboard_header.dart';
import 'widgets/ringkasan_aset.dart';
import 'widgets/carousel.dart';
import 'widgets/panenStatus.dart';
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
  final Map<int, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().refreshAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = context.select<AuthProvider, UserModel?>(
      (auth) => auth.user,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProv, child) {
          if (dashboardProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

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

          final data = dashboardProv.dashboardData;
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () => dashboardProv.fetchDashboard(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                /// HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: DashboardHeader(
                      userName: user?.namaLengkap ?? "Pengguna",
                      userRole: user?.roleDisplay ?? "User",
                    ),
                  ),
                ),

                /// CAROUSEL
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SizedBox(
                      height: 240,
                      child: PromoCarousel(items: dummyCarouselData),
                    ),
                  ),
                ),

                /// TOTAL LAHAN
                SliverToBoxAdapter(
                  child: DashboardSection(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Total Lahan"),
                          const SizedBox(height: 16),
                          if (data.lahanData.isNotEmpty)
                            _buildLahanStatsSection(data.lahanData),
                        ],
                      ),
                    ),
                  ),
                ),

                /// GRAFIK
                SliverToBoxAdapter(
                  child: DashboardSection(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Grafik Pertumbuhan"),
                          const SizedBox(height: 12),
                          if (data.harvestData != null)
                            GrafikChartCard(data: data.harvestData!),
                        ],
                      ),
                    ),
                  ),
                ),

                /// DATA KWARTAL
                SliverToBoxAdapter(
                  child: DashboardSection(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Data Kwartal"),
                          const SizedBox(height: 12),
                          if (data.quarterlyData.isNotEmpty)
                            QuarterlyStatsSection(items: data.quarterlyData),
                        ],
                      ),
                    ),
                  ),
                ),

                /// TOTAL KESELURUHAN
                SliverToBoxAdapter(
                  child: DashboardSection(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Panen Status"),
                          const SizedBox(height: 12),
                          const PanenStatusSection(),
                        ],
                      ),
                    ),
                  ),
                ),

                /// MAP
                SliverToBoxAdapter(
                  child: DashboardSection(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Peta Penyebaran Potensi Lahan"),
                          const SizedBox(height: 12),

                          const PotensiMapSection(),

                          const SizedBox(height: 20),

                          Consumer<DashboardProvider>(
                            builder: (context, prov, _) {
                              if (prov.isWilayahLoading) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              return _buildDistributionSection();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// RESAPAN
                if (data.resapanData != null)
                  SliverToBoxAdapter(
                    child: DashboardSection(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                              "Total Resapan Per Tahun ${data.resapanData!.year}",
                            ),
                            const SizedBox(height: 12),
                            ResapanCard(data: data.resapanData!),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ================= LAHAN SECTION =================

  Widget _buildLahanStatsSection(List<dynamic> lahanData) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 900) {
      return _buildDesktopLayout(lahanData);
    } else if (screenWidth > 600) {
      return _buildTabletLayout(lahanData);
    } else {
      return _buildMobileLayout(lahanData);
    }
  }

  Widget _buildDesktopLayout(List<dynamic> lahanData) {
    return Column(
      children: [
        LahanStatCard(
          key: const ValueKey('featured'),
          data: lahanData[0],
          layoutType: CardLayoutType.list,
          isElevated: true,
          initiallyExpanded: _expandedStates[0] ?? false,
          previewItemCount: 4,
          onTap: () => _onCardTap(lahanData[0]),
        ),
        const SizedBox(height: 16),
        if (lahanData.length > 1)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: lahanData.length - 1,
            itemBuilder: (context, index) {
              final actualIndex = index + 1;
              return LahanStatCard(
                key: ValueKey('lahan_$actualIndex'),
                data: lahanData[actualIndex],
                layoutType: CardLayoutType.list,
                initiallyExpanded: _expandedStates[actualIndex] ?? false,
                previewItemCount: 3,
                onTap: () => _onCardTap(lahanData[actualIndex]),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTabletLayout(List<dynamic> lahanData) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: lahanData.length,
      itemBuilder: (context, index) {
        return LahanStatCard(
          key: ValueKey('lahan_$index'),
          data: lahanData[index],
          layoutType: CardLayoutType.list,
          isElevated: index == 0,
          initiallyExpanded: _expandedStates[index] ?? false,
          previewItemCount: 3,
          onTap: () => _onCardTap(lahanData[index]),
        );
      },
    );
  }

  Widget _buildMobileLayout(List<dynamic> lahanData) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lahanData.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final isFirst = index == 0;
        return LahanStatCard(
          key: ValueKey('lahan_$index'),
          data: lahanData[index],
          layoutType: CardLayoutType.list,
          isElevated: isFirst,
          initiallyExpanded: _expandedStates[index] ?? false,
          previewItemCount: isFirst ? 4 : 3,
          onTap: () => _onCardTap(lahanData[index]),
        );
      },
    );
  }

  Widget _buildDistributionSection() {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 600) {
      return const Row(children: [Expanded(child: DistributionCard())]);
    } else {
      return const Column(children: [DistributionCard()]);
    }
  }

  void _onCardTap(dynamic data) {
    HapticFeedback.lightImpact();
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1E293B),
      ),
    );
  }
}

/// ================= GRID BACKGROUND =================

class DashboardSection extends StatelessWidget {
  final Widget child;

  const DashboardSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _DashboardGridPainter())),
        child,
      ],
    );
  }
}

class _DashboardGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 40.0;

    final paint =
        Paint()
          ..color = const Color(0xFFE2E8F0)
          ..strokeWidth = 0.4;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
