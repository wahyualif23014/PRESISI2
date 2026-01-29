import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/route_names.dart'; // Sesuaikan path

class MainDataSubBottomNav extends StatelessWidget {
  final VoidCallback onClose;

  const MainDataSubBottomNav({super.key, required this.onClose});

  void _handleNavigation(BuildContext context, String route) {
    final GoRouter router = GoRouter.of(context);
    
    // 1. Jalankan callback onClose (ini akan memicu setState di MainDataShellPage)
    //    Efeknya: Menu turun ke bawah, Blur hilang.
    onClose(); 

    // 2. Beri jeda sebentar (150-200ms) agar animasi tutup terlihat mata user
    Future.delayed(const Duration(milliseconds: 150), () {
      // 3. Baru pindah halaman
      router.go(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ... (Sisa code UI Container dan PopupItem Anda tetap sama)
    // Pastikan di bagian onTap item memanggil _handleNavigation
    // Contoh:
    /*
      _PopupItem(
        icon: Icons.map_rounded,
        label: 'Wilayah',
        onTap: () => _handleNavigation(context, RouteNames.dataRegions),
      ),
    */
    
    // Copy sisa code UI Anda di sini...
    const primaryColor = Color(0xFF7C6FDE);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storage_rounded, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Menu Data Utama',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            // MENU ITEMS
            _PopupItem(
              icon: Icons.account_tree_rounded,
              label: 'Tingkat Kesatuan',
              onTap: () => _handleNavigation(context, RouteNames.dataUnits),
            ),
            _PopupItem(
              icon: Icons.badge_rounded,
              label: 'Jabatan',
              onTap: () => _handleNavigation(context, RouteNames.dataPositions),
            ),
            _PopupItem(
              icon: Icons.map_rounded,
              label: 'Wilayah',
              onTap: () => _handleNavigation(context, RouteNames.dataRegions),
            ),
            _PopupItem(
              icon: Icons.local_florist_rounded,
              label: 'Komoditi Lahan',
              isLast: true,
              onTap: () => _handleNavigation(context, RouteNames.dataCommodities),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget _PopupItem
class _PopupItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _PopupItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF7C6FDE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: const Color(0xFF7C6FDE)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 22, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}