import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/presentation/widgets/potensi_map_widget.dart'
    show PotensiMapSection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// --- IMPORT PROVIDER ---
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/providers/dashboard_provider.dart';

// --- IMPORT WIDGETS & MODELS ---
import 'widgets/dashboard_header.dart';
import 'widgets/ringkasan_aset.dart'; // File berisi LahanStatCard & CardLayoutType
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
  // Track expanded states for each card
  final Map<int, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
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
                // A. HEADER SECTION
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: DashboardHeader(
                      userName: user?.namaLengkap ?? "Pengguna",
                      userRole: user?.roleDisplay ?? "User",
                    ),
                  ),
                ),

                // B. CAROUSEL SECTION
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SizedBox(
                      height: 240,
                      child: PromoCarousel(items: dummyCarouselData),
                    ),
                  ),
                ),

                // C. LAHAN STATS SECTION - VERTICAL EXPANDABLE
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
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

                // D. GRAFIK PERTUMBUHAN
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
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

                // E. DATA KWARTAL
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
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

                // F. RINGKASAN KESELURUHAN
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Total Keseluruhan"),
                        const SizedBox(height: 12),
                        TotalSummarySection(items: data.summaryData),
                      ],
                    ),
                  ),
                ),

                // G. PETA PENYEBARAN
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Peta Penyebaran Potensi Lahan"),
                        const SizedBox(height: 12),
                        const PotensiMapSection(),

                        const SizedBox(height: 16),

                        if (data.distributionData.isNotEmpty)
                          _buildDistributionSection(data.distributionData),
                      ],
                    ),
                  ),
                ),

                // H. TOTAL RESAPAN
                if (data.resapanData != null)
                  SliverToBoxAdapter(
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
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== LAHAN STATS SECTION ====================

  Widget _buildLahanStatsSection(List<dynamic> lahanData) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Desktop/Tablet: Grid layout with expandable cards
    if (screenWidth > 900) {
      return _buildDesktopLayout(lahanData);
    }
    // Tablet: 2 column grid
    else if (screenWidth > 600) {
      return _buildTabletLayout(lahanData);
    }
    // Mobile: Vertical stack
    else {
      return _buildMobileLayout(lahanData);
    }
  }

  /// DESKTOP: >900px - 2 column grid, first card spans full width
  Widget _buildDesktopLayout(List<dynamic> lahanData) {
    return Column(
      children: [
        // Featured Card (Full width)
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

        // Grid for remaining cards
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

  /// TABLET: 600-900px - 2 column grid
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

  /// MOBILE: <600px - Vertical stack with expandable cards
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

  // ==================== DISTRIBUTION SECTION ====================

  Widget _buildDistributionSection(List<dynamic> distributionData) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 600) {
      return Row(
        children: [
          Expanded(child: DistributionCard(data: distributionData[0])),
          if (distributionData.length > 1) ...[
            const SizedBox(width: 16),
            Expanded(child: DistributionCard(data: distributionData[1])),
          ],
        ],
      );
    } else {
      return Column(
        children: [
          DistributionCard(data: distributionData[0]),
          if (distributionData.length > 1) ...[
            const SizedBox(height: 12),
            DistributionCard(data: distributionData[1]),
          ],
        ],
      );
    }
  }

  void _onCardTap(dynamic data) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to detail page
    // Navigator.push(context, MaterialPageRoute(...));
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
