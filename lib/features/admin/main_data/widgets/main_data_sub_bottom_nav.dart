import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/route_names.dart';

// --- PALET WARNA EARTHY & ORGANIC ---
const Color _forestGreen = Color(0xFF2D4F1E);
const Color _warmBeige = Color(0xFFF5E6CC);
const Color _slateGrey = Color(0xFF4A4A4A);
const Color _textPrimary = Color(0xFF2C3E2D);
const Color _borderWarm = Color(0xFFE8DDD0);

class MainDataSubBottomNav extends StatelessWidget {
  final VoidCallback onClose;

  const MainDataSubBottomNav({super.key, required this.onClose});

  void _handleNavigation(BuildContext context, String route) {
    final GoRouter router = GoRouter.of(context);
    
    // 1. Jalankan onClose untuk memicu MenuProvider (toggle false)
    onClose(); 
    
    // 2. Beri sedikit delay agar animasi penutupan popup berjalan mulus sebelum pindah page
    Future.delayed(const Duration(milliseconds: 150), () {
      router.go(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _forestGreen.withOpacity(0.12),
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
                color: _forestGreen.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_forestGreen, Color(0xFF1E3A0F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
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
                      color: _textPrimary,
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
      borderRadius: isLast 
          ? const BorderRadius.vertical(bottom: Radius.circular(20)) 
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: _borderWarm, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _warmBeige.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: _forestGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600, 
                  color: _textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 22, color: _slateGrey.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}