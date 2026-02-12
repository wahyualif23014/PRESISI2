import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:KETAHANANPANGAN/features/admin/main_data/regions/data/provider/region_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_search_filter.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_list_item.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_group_headers.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/presentation/widgets/wilayah_filter_widget.dart';

class RegionsPage extends StatefulWidget {
  const RegionsPage({super.key});

  @override
  State<RegionsPage> createState() => _RegionsPageState();
}

class _RegionsPageState extends State<RegionsPage> {
  final TextEditingController _searchController = TextEditingController();
  int _limitKabupaten = 5;

  // Variabel warna utama (Hijau Beras/Pangan Premium)
  final Color primaryGreen = const Color(0xFF00B276);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegionProvider>().fetchRegions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===============================================================
  // 1. PREMIUM GREEN STATISTIC CARD
  // ===============================================================
  Widget _buildPremiumStatCard(int kab, int kec, int desa) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 160,
      child: Stack(
        children: [
          // Background dengan Gradient dan Pattern
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryGreen, const Color(0xFF00895B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          // Elemen Dekoratif (Lingkaran di belakang)
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          // Konten Utama
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Bagian Icon Besar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.map_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 20),
                // Bagian Detail Angka
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "DATA STATISTIK WILAYAH",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        Icons.business_rounded,
                        "$kab",
                        "KABUPATEN",
                      ),
                      const SizedBox(height: 6),
                      _buildStatRow(
                        Icons.account_tree_rounded,
                        "$kec",
                        "KECAMATAN",
                      ),
                      const SizedBox(height: 6),
                      _buildStatRow(
                        Icons.location_city_rounded,
                        "$desa",
                        "DESA",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 14),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // 2. ACTIONS & DIALOGS
  // ===============================================================
  void _showFilterDialog(BuildContext context) {
    final provider = context.read<RegionProvider>();
    showDialog(
      context: context,
      builder:
          (ctx) => WilayahFilterWidget(
            availableKabupaten: provider.uniqueKabupatenList,
            onApply: (selectedFilters) {
              Navigator.pop(ctx);
              provider.applyFilterKabupaten(selectedFilters);
            },
            onReset: () {
              Navigator.pop(ctx);
              provider.applyFilterKabupaten([]);
            },
          ),
    );
  }

  Future<void> _openMap(double lat, double lng) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal buka peta")));
    }
  }

  void _showEditDialog(BuildContext context, dynamic item) {
    final latController = TextEditingController(text: item.latitude.toString());
    final lngController = TextEditingController(
      text: item.longitude.toString(),
    );
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text("Update Lokasi ${item.namaDesa}"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: latController,
                        decoration: const InputDecoration(labelText: "Lat"),
                      ),
                      TextField(
                        controller: lngController,
                        decoration: const InputDecoration(labelText: "Lng"),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed:
                          isSaving
                              ? null
                              : () async {
                                setState(() => isSaving = true);
                                final success = await context
                                    .read<RegionProvider>()
                                    .updateData(
                                      item.id,
                                      double.tryParse(latController.text) ??
                                          0.0,
                                      double.tryParse(lngController.text) ??
                                          0.0,
                                    );
                                if (mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success ? "Berhasil" : "Gagal",
                                      ),
                                    ),
                                  );
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                      ),
                      child: const Text("Simpan"),
                    ),
                  ],
                ),
          ),
    );
  }

  // ===============================================================
  // 3. MAIN BUILD
  // ===============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<RegionProvider>(
        builder: (context, provider, child) {
          final totalKab = provider.uniqueKabupatenList.length;
          final totalKec =
              provider.displayData.map((e) => e.kecamatan).toSet().length;
          final totalDesa = provider.displayData.length;

          return Column(
            children: [
              // A. SEARCH & FILTER (DI ATAS)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: WilayahSearchFilter(
                  controller: _searchController,
                  onChanged: (val) => provider.search(val),
                  onFilterTap: () => _showFilterDialog(context),
                  // Catatan: Pastikan di dalam widget WilayahSearchFilter kamu menggunakan primaryGreen
                ),
              ),

              // B. CARD STATISTIK (DI BAWAH SEARCH)
              _buildPremiumStatCard(totalKab, totalKec, totalDesa),

              // Control Optimasi
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    const Text(
                      "Mode Performa:",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _limitKabupaten,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: primaryGreen,
                        size: 18,
                      ),
                      items:
                          [5, 10, 20]
                              .map(
                                (int v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                    "$v Kab",
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (val) => setState(() => _limitKabupaten = val!),
                    ),
                  ],
                ),
              ),

              // C. LIST DATA
              Expanded(
                child:
                    provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildListWilayah(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListWilayah(RegionProvider provider) {
    final allKabList =
        provider.displayData.map((e) => e.kabupaten).toSet().toList();
    final currentLimitedKab = allKabList.take(_limitKabupaten).toList();
    final dataToRender =
        provider.displayData
            .where((item) => currentLimitedKab.contains(item.kabupaten))
            .toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: dataToRender.length,
      itemBuilder: (context, index) {
        final item = dataToRender[index];
        bool isNewKab =
            index == 0 || dataToRender[index - 1].kabupaten != item.kabupaten;
        bool isNewKec =
            index == 0 ||
            dataToRender[index - 1].kecamatan != item.kecamatan ||
            isNewKab;

        final isKabOpen = provider.isKabupatenExpanded(item.kabupaten);
        final isKecOpen =
            isKabOpen && provider.isKecamatanExpanded(item.kecamatan);

        return Column(
          children: [
            if (isNewKab)
              WilayahKabupatenHeader(
                title: item.kabupaten,
                isExpanded: isKabOpen,
                onTap: () => provider.toggleKabupaten(item.kabupaten),
              ),
            if (isNewKec && isKabOpen)
              WilayahKecamatanHeader(
                title: item.kecamatan,
                isExpanded: isKecOpen,
                onTap: () => provider.toggleKecamatan(item.kecamatan),
              ),
            if (isKecOpen)
              WilayahListItem(
                item: item,
                onMapTap: () => _openMap(item.latitude, item.longitude),
                onEditTap: () => _showEditDialog(context, item),
              ),
          ],
        );
      },
    );
  }
}
