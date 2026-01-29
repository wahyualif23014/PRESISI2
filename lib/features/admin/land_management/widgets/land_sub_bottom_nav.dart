import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/route_names.dart';

class LandSubBottomNav extends StatelessWidget {
  final VoidCallback onClose;

  const LandSubBottomNav({super.key, required this.onClose});

  void _handleNavigation(BuildContext context, String route) {
    final GoRouter router = GoRouter.of(context);
    
    onClose();

    Future.delayed(const Duration(milliseconds: 150), () {
      router.go(route);
    });
  }

  @override
  Widget build(BuildContext context) {
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

            _LandPopupItem(
              icon: Icons.dashboard_rounded,
              label: 'Data Potensi Lahan',
              onTap: () => _handleNavigation(context, RouteNames.landOverview),
            ),
            _LandPopupItem(
              icon: Icons.grid_on_rounded,
              label: 'Data Kelola Lahan',
              onTap: () => _handleNavigation(context, RouteNames.landPlots),
            ),
            _LandPopupItem(
              icon: Icons.local_florist_rounded,
              label: 'Riwayat Kelola Lahan',
              isLast: true,
              onTap: () => _handleNavigation(context, RouteNames.landCrops),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandPopupItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _LandPopupItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7C6FDE);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: isLast 
              ? null 
              : Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon, 
                size: 22, 
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600, 
                  color: Color(0xFF1E293B),
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