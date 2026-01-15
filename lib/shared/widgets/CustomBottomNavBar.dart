import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/router/route_names.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  static const double _navHeight = 80;
  
  // Logic Popup di-disable karena sekarang menggunakan MainDataShellPage
  /*
  bool _isDataOpen = false;
  late AnimationController _popupController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  */

  @override
  void initState() {
    super.initState();
    /*
    _popupController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _popupController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _popupController,
      curve: Curves.easeOut,
    );
    */
  }

  @override
  void dispose() {
    // _popupController.dispose();
    super.dispose();
  }

  /*
  void _toggleData() {
    setState(() {
      _isDataOpen = !_isDataOpen;
      _isDataOpen ? _popupController.forward() : _popupController.reverse();
    });
  }

  void _closeData() {
    if (_isDataOpen) {
      setState(() {
        _isDataOpen = false;
        _popupController.reverse();
      });
    }
  }
  */

  int _getCurrentIndex(String location) {
    if (location.startsWith(RouteNames.recap)) return 0;
    if (location.startsWith(RouteNames.data)) return 1;
    if (location.startsWith(RouteNames.dashboard)) return 2;
    if (location.startsWith(RouteNames.landManagement)) return 3;
    if (location.startsWith(RouteNames.personnel)) return 4;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final location = GoRouterState.of(context).uri.toString();
    final itemWidth = size.width / 5;
    
    // Index sekarang murni berdasarkan lokasi URL (tanpa state _isDataOpen)
    final currentIndex = _getCurrentIndex(location);

    return SizedBox(
      // Tinggi tetap karena tidak ada popup melayang di dalam widget ini lagi
      height: _navHeight + 30,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. BACKDROP (DISABLED)
          /*
          if (_isDataOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeData,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                ),
              ),
            ),
          */

          // 2. DATA POPUP (DISABLED - Sudah pindah ke Shell Module Data)
          /*
          if (_isDataOpen)
            Positioned(
              bottom: _navHeight + 20,
              left: 0,
              right: 0,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: MainDataSubBottomNav(onClose: _closeData),
                ),
              ),
            ),
          */

          // 3. MAIN NAV BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomNavBarContent(
              currentIndex: currentIndex,
              itemWidth: itemWidth,
              primaryColor: const Color(0xFF7C6FDE),
              inactiveColor: const Color(0xFF94A3B8),
              backgroundColor: Colors.white,
              onRecapTap: () => context.go(RouteNames.recap),
              // PENTING: Sekarang langsung navigasi ke Route Data
              onDataTap: () => context.go(RouteNames.data), 
              onHomeTap: () => context.go(RouteNames.dashboard),
              onLandTap: () => context.go(RouteNames.landManagement),
              onPersonnelTap: () => context.go(RouteNames.personnel),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// UI COMPONENTS (NAVBAR CONTENT, CURVE, ITEMS) - TETAP SAMA
// ============================================================================

class _BottomNavBarContent extends StatelessWidget {
  final int currentIndex;
  final double itemWidth;
  final Color primaryColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final VoidCallback onRecapTap;
  final VoidCallback onDataTap;
  final VoidCallback onHomeTap;
  final VoidCallback onLandTap;
  final VoidCallback onPersonnelTap;

  const _BottomNavBarContent({
    required this.currentIndex,
    required this.itemWidth,
    required this.primaryColor,
    required this.inactiveColor,
    required this.backgroundColor,
    required this.onRecapTap,
    required this.onDataTap,
    required this.onHomeTap,
    required this.onLandTap,
    required this.onPersonnelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _AnimatedCurveBackground(
            currentIndex: currentIndex,
            itemWidth: itemWidth,
            backgroundColor: backgroundColor,
          ),
          Row(
            children: [
              _NavBarItem(index: 0, currentIndex: currentIndex, width: itemWidth, label: "Rekap", icon: Icons.print_outlined, activeIcon: Icons.print_rounded, primaryColor: primaryColor, inactiveColor: inactiveColor, onTap: onRecapTap),
              _NavBarItem(index: 1, currentIndex: currentIndex, width: itemWidth, label: "Data", icon: Icons.storage_outlined, activeIcon: Icons.storage_rounded, primaryColor: primaryColor, inactiveColor: inactiveColor, onTap: onDataTap),
              _NavBarItem(index: 2, currentIndex: currentIndex, width: itemWidth, label: "Beranda", icon: Icons.home_outlined, activeIcon: Icons.home_rounded, primaryColor: primaryColor, inactiveColor: inactiveColor, onTap: onHomeTap),
              _NavBarItem(index: 3, currentIndex: currentIndex, width: itemWidth, label: "Lahan", icon: Icons.spa_outlined, activeIcon: Icons.spa_rounded, primaryColor: primaryColor, inactiveColor: inactiveColor, onTap: onLandTap),
              _NavBarItem(index: 4, currentIndex: currentIndex, width: itemWidth, label: "Personel", icon: Icons.person_outline, activeIcon: Icons.person_rounded, primaryColor: primaryColor, inactiveColor: inactiveColor, onTap: onPersonnelTap),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final double width;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Color primaryColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.index,
    required this.currentIndex,
    required this.width,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.primaryColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              top: isSelected ? 8 : 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    padding: EdgeInsets.all(isSelected ? 12 : 0),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: isSelected ? [
                        BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
                      ] : [],
                    ),
                    child: Icon(isSelected ? activeIcon : icon, size: 24, color: isSelected ? Colors.white : inactiveColor),
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

class _AnimatedCurveBackground extends StatelessWidget {
  final int currentIndex;
  final double itemWidth;
  final Color backgroundColor;

  const _AnimatedCurveBackground({required this.currentIndex, required this.itemWidth, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: currentIndex.toDouble()),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      builder: (context, value, _) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 80),
          painter: _CurvePainter(position: value, itemWidth: itemWidth, color: backgroundColor),
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
    final curveWidth = itemWidth * 0.75;
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