import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/router/route_names.dart'; // Pastikan path benar

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  static const double _navHeight = 80;

  // Logika penentuan index berdasarkan rute aktif saat ini
  int _getCurrentIndex(String location) {
    if (location.startsWith(RouteNames.recap)) return 0;
    if (location.startsWith(RouteNames.data)) return 1;
    if (location.startsWith(RouteNames.dashboard)) return 2;
    if (location.startsWith(RouteNames.landManagement)) return 3;
    if (location.startsWith(RouteNames.personnel)) return 4;
    return 2; // Default ke Beranda
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final location = GoRouterState.of(context).uri.toString();
    final itemWidth = size.width / 5;
    final currentIndex = _getCurrentIndex(location);

    return Container(
      height: _navHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Animasi Background Curve (Latar belakang putih yang melengkung)
          _AnimatedCurveBackground(
            currentIndex: currentIndex,
            itemWidth: itemWidth,
            backgroundColor: Colors.white,
          ),

          // 2. Barisan Item Navigasi
          Row(
            children: [
              _NavBarItem(
                index: 0,
                currentIndex: currentIndex,
                width: itemWidth,
                label: "Rekap",
                icon: Icons.print_outlined,
                activeIcon: Icons.print_rounded,
                onTap: () => context.go(RouteNames.recap),
              ),
              _NavBarItem(
                index: 1,
                currentIndex: currentIndex,
                width: itemWidth,
                label: "Data",
                icon: Icons.storage_outlined,
                activeIcon: Icons.storage_rounded,
                onTap: () => context.go(RouteNames.data), 
              ),
              _NavBarItem(
                index: 2,
                currentIndex: currentIndex,
                width: itemWidth,
                label: "Beranda",
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                onTap: () => context.go(RouteNames.dashboard),
              ),
              _NavBarItem(
                index: 3,
                currentIndex: currentIndex,
                width: itemWidth,
                label: "Lahan",
                icon: Icons.spa_outlined,
                activeIcon: Icons.spa_rounded,
                onTap: () => context.go(RouteNames.landManagement),
              ),
              _NavBarItem(
                index: 4,
                currentIndex: currentIndex,
                width: itemWidth,
                label: "Personel",
                icon: Icons.person_outline,
                activeIcon: Icons.person_rounded,
                onTap: () => context.go(RouteNames.personnel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SUB-WIDGETS (Sama dengan kode Anda namun dengan pembersihan variabel)
// ============================================================================

class _NavBarItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final double width;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.index,
    required this.currentIndex,
    required this.width,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    const primaryColor = Color(0xFF7C6FDE);
    const inactiveColor = Color(0xFF94A3B8);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: isSelected ? 8 : 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.all(isSelected ? 12 : 0),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: isSelected 
                        ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] 
                        : [],
                    ),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      size: 24,
                      color: isSelected ? Colors.white : inactiveColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? primaryColor : inactiveColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Painter tetap sama untuk menjaga UI Curve yang bagus
class _AnimatedCurveBackground extends StatelessWidget {
  final int currentIndex;
  final double itemWidth;
  final Color backgroundColor;

  const _AnimatedCurveBackground({
    required this.currentIndex, 
    required this.itemWidth, 
    required this.backgroundColor
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: currentIndex.toDouble()),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 80),
          painter: _CurvePainter(
            position: value, 
            itemWidth: itemWidth, 
            color: backgroundColor
          ),
        );
      },
    );
  }
}

class _CurvePainter extends CustomPainter {
  final double position;
  final double itemWidth;
  final Color color;

  _CurvePainter({required this.position, required this.itemWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();

    final centerX = (position * itemWidth) + (itemWidth / 2);
    const curveDepth = 22.0;
    final curveWidth = itemWidth * 0.8;
    final curveStart = centerX - (curveWidth / 2);
    final curveEnd = centerX + (curveWidth / 2);

    path.moveTo(0, 0);
    path.lineTo(curveStart - 16, 0);
    path.cubicTo(curveStart - 8, 0, curveStart, -curveDepth * 0.5, curveStart, -curveDepth * 0.6);
    path.cubicTo(curveStart + 10, -curveDepth, curveEnd - 10, -curveDepth, curveEnd, -curveDepth * 0.6);
    path.cubicTo(curveEnd, -curveDepth * 0.5, curveEnd + 8, 0, curveEnd + 16, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.06), 4, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) => oldDelegate.position != position;
}