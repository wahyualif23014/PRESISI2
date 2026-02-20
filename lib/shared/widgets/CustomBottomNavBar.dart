import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:KETAHANANPANGAN/auth/models/role_enum.dart';
import 'package:KETAHANANPANGAN/router/route_names.dart';

class CustomBottomNavBar extends StatelessWidget {
  final UserRole role;
  
  static const double _navHeight = 80.0;
  
  const CustomBottomNavBar({super.key, required this.role});

  List<_NavItemModel> _getNavItems(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [
          const _NavItemModel(
            label: "Rekap", 
            icon: Icons.print_outlined, 
            activeIcon: Icons.print_rounded, 
            route: RouteNames.recap
          ),
          const _NavItemModel(
            label: "Data Utama", 
            icon: Icons.map_outlined, 
            activeIcon: Icons.map_rounded, 
            route: RouteNames.data
          ),
          const _NavItemModel(
            label: "Beranda", 
            icon: Icons.home_outlined, 
            activeIcon: Icons.home_rounded, 
            route: RouteNames.dashboard
          ),
          const _NavItemModel(
            label: "Kelola Lahan", 
            icon: Icons.spa_outlined, 
            activeIcon: Icons.spa_rounded, 
            route: RouteNames.landManagement
          ),
          const _NavItemModel(
            label: "Personel", 
            icon: Icons.people_outline, 
            activeIcon: Icons.people_rounded, 
            route: RouteNames.personnel
          ),
        ];
      
      case UserRole.operator:
        return [
          const _NavItemModel(
            label: "Potensi",
            icon: Icons.terrain_outlined, 
            activeIcon: Icons.terrain_rounded, 
            route: RouteNames.landOverview
          ),
          const _NavItemModel(
            label: "Kelola",
            icon: Icons.spa_outlined, 
            activeIcon: Icons.spa_rounded, 
            route: RouteNames.landPlots
          ),
          const _NavItemModel(
            label: "Beranda",
            icon: Icons.home_outlined, 
            activeIcon: Icons.home_rounded, 
            route: RouteNames.dashboard
          ),
          const _NavItemModel(
            label: "Riwayat",
            icon: Icons.history_outlined, 
            activeIcon: Icons.history_rounded, 
            route: RouteNames.landCrops
          ),
          const _NavItemModel(
            label: "Rekap",
            icon: Icons.print_outlined, 
            activeIcon: Icons.print_rounded, 
            route: RouteNames.recap
          ),
        ];
      
      case UserRole.view:
      default:
        return [
          const _NavItemModel(
            label: "Rekap", 
            icon: Icons.print_outlined, 
            activeIcon: Icons.print_rounded, 
            route: RouteNames.recap
          ),
          const _NavItemModel(
            label: "Beranda", 
            icon: Icons.home_outlined, 
            activeIcon: Icons.home_rounded, 
            route: RouteNames.dashboard
          ),
          const _NavItemModel(
            label: "Profil", 
            icon: Icons.person_outline, 
            activeIcon: Icons.person_rounded, 
            route: RouteNames.profile
          ),
        ];
    }
  }

  int _calculateSelectedIndex(String location, List<_NavItemModel> items) {
    for (int i = 0; i < items.length; i++) {
      if (location == items[i].route) return i;
    }
    
    if (location.startsWith(RouteNames.landManagement)) {
      for (int i = 0; i < items.length; i++) {
        if (items[i].route == RouteNames.landManagement) return i;
      }
    }
    
    if (location.startsWith('/data/')) {
      for (int i = 0; i < items.length; i++) {
        if (items[i].route == RouteNames.data) return i;
      }
    }
    
    for (int i = 0; i < items.length; i++) {
      final route = items[i].route;
      if (location.startsWith(route) && route != '/') {
        return i;
      }
    }
    
    return items.length > 3 ? 2 : (items.length ~/ 2);
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _getNavItems(role);

    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    if (isKeyboardOpen) return const SizedBox.shrink();
    
    final size = MediaQuery.of(context).size;
    
    String location;
    try {
      location = GoRouterState.of(context).uri.toString();
    } catch (e) {
      location = RouteNames.dashboard;
    }
    
    final currentIndex = _calculateSelectedIndex(location, navItems);
    final itemWidth = size.width / navItems.length;

    // ✅ OPTIMASI: Gunakan RepaintBoundary untuk mengurangi repaint
    return RepaintBoundary(
      child: SizedBox(
        height: _navHeight,
        width: size.width,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ✅ OPTIMASI: CustomPaint dengan cache
            _NavCurveBackground(
              currentIndex: currentIndex,
              itemWidth: itemWidth,
              height: _navHeight,
            ),
            // ✅ OPTIMASI: Row tanpa LayoutBuilder, gunakan SizedBox.expand
            SizedBox.expand(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(navItems.length, (index) {
                  final isSelected = index == currentIndex;
                  return Expanded(
                    child: _NavBarItem(
                      data: navItems[index],
                      isSelected: isSelected,
                      onTap: () {
                        final route = navItems[index].route;
                        if (route.isNotEmpty) {
                          HapticFeedback.lightImpact();
                          context.go(route);
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemModel {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItemModel({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

class _NavBarItem extends StatelessWidget {
  final _NavItemModel data;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color primaryColor = Color(0xFF10B981);
  static const Color inactiveColor = Color(0xFF64748B);

  const _NavBarItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      // ✅ OPTIMASI: Container dengan constraint yang jelas
      child: SizedBox.expand(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ OPTIMASI: AnimatedContainer dengan transform yang smooth
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.translationValues(0, isSelected ? -20 : 0, 0),
              padding: EdgeInsets.all(isSelected ? 14 : 8),
              decoration: isSelected
                ? BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 15.0,
                        spreadRadius: 0.0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  )
                : const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
              child: Icon(
                isSelected ? data.activeIcon : data.icon,
                size: isSelected ? 28 : 24,
                color: isSelected ? Colors.white : inactiveColor,
              ),
            ),
            const SizedBox(height: 4),
            // ✅ OPTIMASI: Text tanpa shadow yang bermasalah
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? primaryColor : inactiveColor,
                letterSpacing: 0.2,
                // ✅ FIX: Tidak ada shadows property
              ),
              child: Text(data.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCurveBackground extends StatelessWidget {
  final int currentIndex;
  final double itemWidth;
  final double height;

  const _NavCurveBackground({
    required this.currentIndex,
    required this.itemWidth,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ OPTIMASI: TweenAnimationBuilder dengan proper caching
    return TweenAnimationBuilder<double>(
      key: ValueKey(currentIndex), // ✅ Membantu Flutter mengidentifikasi animasi
      tween: Tween(end: currentIndex.toDouble()),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, height),
          painter: _NavCurvePainter(
            position: value,
            itemWidth: itemWidth,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

class _NavCurvePainter extends CustomPainter {
  final double position;
  final double itemWidth;
  final Color color;

  _NavCurvePainter({
    required this.position,
    required this.itemWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    final safePosition = position.isFinite ? position : 0;
    final centerX = (safePosition * itemWidth) + (itemWidth / 2);

    const curveDepth = 25.0;
    final curveWidth = itemWidth * 0.8;
    final curveStart = centerX - (curveWidth / 2);
    final curveEnd = centerX + (curveWidth / 2);

    final safeCurveStart = curveStart.isFinite && curveStart >= 0 ? curveStart : 0;
    final safeCurveEnd = curveEnd.isFinite && curveEnd <= size.width ? curveEnd : size.width;
    final safeCenterX = centerX.isFinite ? centerX : size.width / 2;

    path.moveTo(0, 0);
    path.lineTo(safeCurveStart - 15, 0);
    path.cubicTo(
      safeCurveStart - 5,
      0,
      safeCurveStart + 10,
      -curveDepth,
      safeCenterX,
      -curveDepth,
    );
    path.cubicTo(
      safeCurveEnd - 10,
      -curveDepth,
      safeCurveEnd + 5,
      0,
      safeCurveEnd + 15,
      0,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // ✅ OPTIMASI: Shadow dengan nilai yang valid
    canvas.drawShadow(path, Colors.black.withOpacity(0.1), 10, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NavCurvePainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.itemWidth != itemWidth ||
        oldDelegate.color != color;
  }
}