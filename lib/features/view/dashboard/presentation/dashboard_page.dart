// lib/features/view/dashboard/presentation/dashboard_page.dart

import 'package:KETAHANANPANGAN/features/view/dashboard/data/models/viewer_dashboard_model.dart';
import 'package:KETAHANANPANGAN/features/view/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewerDashboardPage extends StatefulWidget {
  const ViewerDashboardPage({super.key});

  @override
  State<ViewerDashboardPage> createState() => _ViewerDashboardPageState();
}

class _ViewerDashboardPageState extends State<ViewerDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViewerDashboardProvider>().fetchViewerData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Monitoring Ketahanan Pangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context.read<ViewerDashboardProvider>().fetchViewerData(),
          ),
        ],
      ),
      body: Consumer<ViewerDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          
          if (provider.errorMessage != null) {
            return Center(child: Text("Error: ${provider.errorMessage}"));
          }

          final data = provider.data;

          return RefreshIndicator(
            onRefresh: () => provider.fetchViewerData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildInsightCard(data),
                const SizedBox(height: 20),
                const Text("Statistik Produksi Wilayah", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                // List Sebaran Wilayah
                ...data.sebaranWilayah.map((s) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_city, color: Colors.blue),
                    title: Text("Wilayah ${s.wilayah}"),
                    trailing: Text("${s.nilai} Ton", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )),
                
                const SizedBox(height: 20),
                _buildInfoBanner(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightCard(ViewerDashboardModel data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text("Capaian Produksi Nasional", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text("${data.persentaseTarget}%", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallStat("Total Produksi", "${data.totalProduksi} T"),
              _buildSmallStat("Titik Lahan", "${data.totalTitikLahan}"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber),
          SizedBox(width: 12),
          Expanded(child: Text("Data diperbarui secara otomatis setiap 24 jam.", style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}