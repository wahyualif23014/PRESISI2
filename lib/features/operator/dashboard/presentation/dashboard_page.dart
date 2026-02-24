// lib/features/operator/dashboard/presentation/dashboard_page.dart

import 'package:KETAHANANPANGAN/features/operator/dashboard/data/model/operator_dashboard_model.dart';
import 'package:KETAHANANPANGAN/features/operator/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';

class OperatorDashboardPage extends StatefulWidget {
  const OperatorDashboardPage({super.key});

  @override
  State<OperatorDashboardPage> createState() => _OperatorDashboardPageState();
}

class _OperatorDashboardPageState extends State<OperatorDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Fetch data otomatis saat page terbuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OperatorDashboardProvider>().fetchOperatorData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard Operator'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OperatorDashboardProvider>().fetchOperatorData(),
          ),
        ],
      ),
      body: Consumer<OperatorDashboardProvider>(
        builder: (context, provider, child) {
          // 1. Loading State
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Error: ${provider.errorMessage}"),
                  ElevatedButton(
                    onPressed: () => provider.fetchOperatorData(),
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            );
          }

          final data = provider.data;

          return RefreshIndicator(
            onRefresh: () => provider.fetchOperatorData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Welcome Header
                // _buildHeader(auth.currentUser?.username ?? 'Operator'),
                
                const SizedBox(height: 24),
                _buildSectionTitle("Statistik Lahan"),
                const SizedBox(height: 12),

                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard("Total Lahan", "${data.totalLahan}", Icons.map, Colors.blue),
                    _buildStatCard("Tugas Pending", "${data.tugasPending}", Icons.assignment_late, Colors.orange),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionTitle("Daftar Lahan Anda"),
                const SizedBox(height: 12),

                // List Lahan
                if (data.daftarLahan.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Belum ada data lahan."),
                  ))
                else
                  ...data.daftarLahan.map((lahan) => _buildLahanTile(lahan)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Halo, $name!", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("Pantau dan kelola data lahan hari ini.", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLahanTile(LahanOperator lahan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lahan.status == 'Aktif' ? Colors.green[50] : Colors.orange[50],
          child: Icon(Icons.eco, color: lahan.status == 'Aktif' ? Colors.green : Colors.orange),
        ),
        title: Text(lahan.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(lahan.lokasi),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}