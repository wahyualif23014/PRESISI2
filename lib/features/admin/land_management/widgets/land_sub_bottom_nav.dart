import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/route_names.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/route_names.dart';

class LandSubBottomNav extends StatelessWidget {
  final VoidCallback? onClose; // ✅ STEP 1

  const LandSubBottomNav({super.key, this.onClose});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.endsWith('/overview')) return 0;
    if (location.endsWith('/plots')) return 1;
    if (location.endsWith('/crops')) return 2;

    return 0;
  }

  void _onTap(BuildContext context, int index) {
    // ✅ TUTUP POPUP DENGAN AMAN
    onClose?.call();

    // ✅ NAVIGASI go_router
    switch (index) {
      case 0:
        context.go(RouteNames.landOverview);
        break;
      case 1:
        context.go(RouteNames.landPlots);
        break;
      case 2:
        context.go(RouteNames.landCrops);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

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
            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF7C6FDE).withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C6FDE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Menu Lahan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),

            // ================= MENU =================
            _LandMenuItem(
              isActive: currentIndex == 0,
              icon: Icons.dashboard_rounded,
              label: 'Data Potensi Lahan',
              onTap: () => _onTap(context, 0),
            ),
            _LandMenuItem(
              isActive: currentIndex == 1,
              icon: Icons.grid_on_rounded,
              label: 'Data Kelola Lahan',
              onTap: () => _onTap(context, 1),
            ),
            _LandMenuItem(
              isActive: currentIndex == 2,
              icon: Icons.local_florist_rounded,
              label: 'Riwayat Kelola Lahan',
              onTap: () => _onTap(context, 2),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _LandMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;
  final bool isActive;

  const _LandMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isActive,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7C6FDE);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.06) : null,
          border:
              isLast
                  ? null
                  : Border(
                    bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isActive ? primaryColor : const Color(0xFF1E293B),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
