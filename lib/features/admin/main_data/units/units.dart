import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/providers/unit_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/data/models/unit_model.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/presentation/widgets/unit_filter_dialog.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/presentation/widgets/unit_search_bar.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/presentation/widgets/unit_item_card.dart';

class UnitsPage extends StatefulWidget {
  const UnitsPage({super.key});

  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnitProvider>().fetchUnits();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UnitProvider>();
    final connectionColor = Colors.grey.shade300;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFEAF0F9),
      body: RefreshIndicator(
        onRefresh: () => provider.refresh(),
        color: const Color(0xFF1E40AF),
        child: CustomScrollView(
          slivers: [
            // ✅ HEADER DENGAN STATS
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.info_outline,
                            value: '${provider.totalPolres}',
                            label: 'POLRES',
                            accentColor: const Color(0xFF1E40AF),
                            bgColor: const Color(0xFFDBEAFE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.info_outline,
                            value: '${provider.totalPolsek}',
                            label: 'POLSEK',
                            accentColor: const Color(0xFF0D9488),
                            bgColor: const Color(0xFFCCFBF1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    UnitSearchFilter(
                      controller: _searchController,
                      onChanged: (value) => provider.search(value),
                      onFilterTap: () => _showFilterDialog(context, provider),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ CONTENT
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: _buildContent(provider, connectionColor),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ STATS CARD WIDGET
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color accentColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Roboto'),
                children: [
                  TextSpan(
                    text: 'TERDAPAT ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  TextSpan(
                    text: ' $label',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ CONTENT BUILDER
  Widget _buildContent(UnitProvider provider, Color connectionColor) {
    if (provider.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.errorMessage != null) {
      return SliverFillRemaining(
        child: _buildErrorState(provider.errorMessage!),
      );
    }

    if (provider.units.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final region = provider.units[index];
        return _buildRegionCard(
          context,
          region,
          index,
          provider,
          connectionColor,
        );
      }, childCount: provider.units.length),
    );
  }

  // ✅ REGION CARD (POLRES + POLSEK)
  Widget _buildRegionCard(
    BuildContext context,
    dynamic region,
    int index,
    UnitProvider provider,
    Color connectionColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // POLRES CARD
          UnitItemCard(
            unit: UnitModel(
              title: region.polres.namaPolres,
              subtitle: _buildPolresSubtitle(region.polres),
              count: '${region.polseks.length} POLSEK',
              phoneNumber: region.polres.noTelp,
              isPolres: true,
            ),
            isExpanded: region.isExpanded,
            onExpandTap: () => provider.toggleExpand(index),
            onPhoneTap:
                region.polres.noTelp != '-'
                    ? () =>
                        _makePhoneCall(context, region.polres.noTelp, provider)
                    : null,
          ),

          // POLSEK LIST (EXPANDED)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildPolsekList(region, connectionColor, provider),
            crossFadeState:
                region.isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  // ✅ BUILD POLRES SUBTITLE (Format: KAPOLRES AKBP ... / +62 ...)
  String _buildPolresSubtitle(dynamic polres) {
    final parts = <String>[];
    if (polres.kapolres.isNotEmpty && polres.kapolres != '-') {
      parts.add('Ka: ${polres.kapolres}');
    }
    // if (polres.noTelp.isNotEmpty && polres.noTelp != '-') {
    //   parts.add(polres.noTelp);
    // }
    return parts.join(' / ');
  }

  Widget _buildPolsekList(
    dynamic region,
    Color connectionColor,
    UnitProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 24, top: 8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: connectionColor, width: 2)),
      ),
      child: Column(
        children:
            region.polseks.map<Widget>((polsek) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Horizontal connector
                    Container(
                      width: 10,
                      height: 2,
                      margin: const EdgeInsets.only(top: 24),
                      color: connectionColor,
                    ),
                    // Polsek Card
                    Expanded(
                      child: UnitItemCard(
                        unit: UnitModel(
                          title: polsek.namaPolsek,
                          subtitle: _buildPolsekSubtitle(polsek),
                          count: polsek.wilayah?.kabupaten ?? '-',
                          phoneNumber: polsek.noTelp,
                          isPolres: false,
                        ),
                        isExpanded: false,
                        onPhoneTap:
                            polsek.noTelp != '-'
                                ? () => _makePhoneCall(
                                  context,
                                  polsek.noTelp,
                                  provider,
                                )
                                : null,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  // ✅ BUILD POLSEK SUBTITLE
  String _buildPolsekSubtitle(dynamic polsek) {
    final parts = <String>[];
    if (polsek.kapolsek.isNotEmpty && polsek.kapolsek != '-') {
      parts.add('Ka: ${polsek.kapolsek}');
    }
    // if (polsek.noTelp.isNotEmpty && polsek.noTelp != '-') {
    //   parts.add(polsek.noTelp);
    // }
    return parts.join(' / ');
  }

  // ✅ PHONE CALL HANDLER
  Future<void> _makePhoneCall(
    BuildContext context,
    String phoneNumber,
    UnitProvider provider,
  ) async {
    // Copy to clipboard feedback
    await Clipboard.setData(ClipboardData(text: phoneNumber));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nomor $phoneNumber disalin ke clipboard'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'HUBUNGI',
            onPressed: () => provider.makePhoneCall(phoneNumber),
          ),
        ),
      );
    }
  }

  // ✅ FILTER DIALOG
  void _showFilterDialog(BuildContext context, UnitProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => UnitFilterDialog(
            initialPolres: provider.showPolres,
            initialPolsek: provider.showPolsek,
            initialWilayah: provider.selectedWilayah,
            availableWilayahs: provider.uniqueWilayahList,
            onApply: (isPolres, isPolsek, wilayah, query) {
              if (query.isNotEmpty) {
                _searchController.text = query;
              }
              provider.applyFilter(
                isPolres,
                isPolsek,
                wilayah,
                _searchController.text,
              );
            },
            onReset: () {
              _searchController.clear();
              provider.resetFilter();
            },
          ),
    );
  }

  // ✅ EMPTY STATE
  static Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Data tidak ditemukan",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Coba ubah filter atau kata kunci pencarian",
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ✅ ERROR STATE
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              "Terjadi Kesalahan",
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<UnitProvider>().refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E40AF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
