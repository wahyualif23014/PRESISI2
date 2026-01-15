import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../auth/provider/auth_provider.dart';
import '../shared/widgets/CustomBottomNavBar.dart';

import 'package:flutter/material.dart';
import '../shared/widgets/CustomBottomNavBar.dart';
// import '../shared/widgets/top_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  static const double _bottomNavHeight = 80;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // ⬅️ PENTING (BIAR CURVE KEPAKE)
      backgroundColor: const Color(0xFFF4F6F9),

      // ======================
      // TOP BAR
      // ======================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _TopBar(),
      ),

      // ======================
      // BODY + NAVBAR
      // ======================
      body: Stack(
        children: [
          // ===== CONTENT =====
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: _bottomNavHeight),
              child: child,
            ),
          ),

          // ===== BOTTOM NAV =====
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(),
          ),
        ],
      ),
    );
  }
}



// --- WIDGET TOPBAR YANG DIPERBAIKI ---
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final String location = GoRouterState.of(context).uri.toString();

    // Data User
    final String userName = auth.user?.nama ?? "Tamu";
    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : "U";

    // Menentukan Judul berdasarkan Lokasi
    String title = "PRESISI SYSTEM";
    if (location.contains('dashboard')) title = "DASHBOARD";
    else if (location.contains('units')) title = "DATA KESATUAN";
    else if (location.contains('land')) title = "KELOLA LAHAN";
    else if (location.contains('recap')) title = "REKAPITULASI";
    else if (location.contains('personnel')) title = "DATA PERSONEL";
    else if (location.contains('positions')) title = "DATA JABATAN";
    else if (location.contains('regions')) title = "DATA WILAYAH";
    else if (location.contains('commodities')) title = "DATA KOMODITAS";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70, // Tinggi fix agar alignment vertikal pas
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Pastikan vertikal center
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: Colors.black54),
                splashRadius: 24, // Efek klik lebih rapi
                tooltip: "Notifikasi",
              ),

              // --- TENGAH: Judul Halaman ---
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800, // Lebih tebal dikit
                        fontSize: 16, // Ukuran pas
                        color: Color(0xFF1E293B), // Slate 800
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Sistem Ketahanan Pangan",
                      style: TextStyle(
                        fontSize: 10, 
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // --- KANAN (END): Profil Dropdown ---
              PopupMenuButton(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Menu tumpul
                child: Container(
                  padding: const EdgeInsets.all(2), // Border putih tipis
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: CircleAvatar(
                    radius: 16, // Ukuran avatar
                    backgroundColor: Colors.orange.shade700,
                    child: Text(
                      initial, 
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthProvider>().logout();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Halo, $userName", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Text("Administrator", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        const Divider(),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.black87, size: 20),
                        SizedBox(width: 10),
                        Text("Profil Saya", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 10),
                        Text("Keluar", style: TextStyle(color: Colors.red, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}