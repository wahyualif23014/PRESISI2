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
  bool _isDataOpen = false;
  late AnimationController _popupController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _popupController = AnimationController(
      duration: const Duration(milliseconds: 250),
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
  }

  @override
  void dispose() {
    _popupController.dispose();
    super.dispose();
  }

  void _toggleData() {
    setState(() {
      _isDataOpen = !_isDataOpen;
      if (_isDataOpen) {
        _popupController.forward();
      } else {
        _popupController.reverse();
      }
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final String location = GoRouterState.of(context).uri.toString();

    const Color primaryColor = Color(0xFF7C6FDE);
    const Color inactiveColor = Color(0xFF94A3B8);
    const Color backgroundColor = Colors.white;

    final double itemWidth = size.width / 5;
    int currentIndex = _isDataOpen ? 1 : _getCurrentIndex(location);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ===============================
        // BACKDROP BLUR - TAP TO CLOSE
        // ===============================
        if (_isDataOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeData,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),
            ),
          ),

        // ===============================
        // DATA POPUP - POSITIONED ABOVE NAV
        // ===============================
        if (_isDataOpen)
          Positioned(
            bottom: 105,
            left: 0,
            right: 0,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _DataPopup(
                  onSelect: (route) {
                    _closeData();
                    Future.delayed(const Duration(milliseconds: 200), () {
                      context.go(route);
                    });
                  },
                ),
              ),
            ),
          ),

        // ===============================
        // BOTTOM NAVIGATION BAR
        // ===============================
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _BottomNavBarContent(
            currentIndex: currentIndex,
            itemWidth: itemWidth,
            primaryColor: primaryColor,
            inactiveColor: inactiveColor,
            backgroundColor: backgroundColor,
            onRecapTap: () {
              _closeData();
              context.go(RouteNames.recap);
            },
            onDataTap: _toggleData,
            onHomeTap: () {
              _closeData();
              context.go(RouteNames.dashboard);
            },
            onLandTap: () {
              _closeData();
              context.go(RouteNames.landManagement);
            },
            onPersonnelTap: () {
              _closeData();
              context.go(RouteNames.personnel);
            },
          ),
        ),
      ],
    );
  }

  int _getCurrentIndex(String location) {
    if (location == RouteNames.recap) return 0;
    if (location.startsWith('/units') ||
        location.startsWith('/positions') ||
        location.startsWith('/regions') ||
        location.startsWith('/commodities'))
      return 1;
    if (location == RouteNames.dashboard) return 2;
    if (location.startsWith('/land')) return 3;
    if (location.startsWith('/personnel')) return 4;
    return 2;
  }
}

// ============================================================================
// BOTTOM NAV BAR CONTENT
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
    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background dengan curve
          _AnimatedCurveBackground(
            currentIndex: currentIndex,
            itemWidth: itemWidth,
            backgroundColor: backgroundColor,
          ),
          // Nav items
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _NavBarItem(
                index: 0,
                currentIndex: currentIndex,
                width: itemWidth,
                label: "Rekap",
                icon: Icons.print_outlined,
                activeIcon: Icons.print_rounded,
                primaryColor: primaryColor,
                inactiveColor: inactiveColor,
                onTap: onRecapTap,
              ),
              _NavBarItem(
                index: 1,
                currentIndex: currentIndex,
                width: itemWidth,
                label: "Data",
                icon: Icons.storage_outlined,
                activeIcon: Icons.storage_rounded,
                primaryColor: primaryColor,
                inactiveColor: inactiveColor,
                onTap: onDataTap,
              ),
              _NavBarItem(
                index: 2,
                currentIndex: currentIndex,
                width: itemWidth,
                label: "Beranda",
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                primaryColor: primaryColor,
                inactiveColor: inactiveColor,
                onTap: onHomeTap,
              ),
              _NavBarItem(
                index: 3,
                currentIndex: currentIndex,
                width: itemWidth,
                label: "Lahan",
                icon: Icons.spa_outlined,
                activeIcon: Icons.spa_rounded,
                primaryColor: primaryColor,
                inactiveColor: inactiveColor,
                onTap: onLandTap,
              ),
              _NavBarItem(
                index: 4,
                currentIndex: currentIndex,
                width: itemWidth,
                label: "Personel",
                icon: Icons.person_outline,
                activeIcon: Icons.person_rounded,
                primaryColor: primaryColor,
                inactiveColor: inactiveColor,
                onTap: onPersonnelTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DATA POPUP WITH IMPROVED LAYOUT
// ============================================================================

class _DataPopup extends StatelessWidget {
  final Function(String route) onSelect;

  const _DataPopup({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6FDE).withOpacity(0.08),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C6FDE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.storage_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Menu Data',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              // Menu Items
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _DataMenuItem(
                      icon: Icons.account_tree_rounded,
                      label: 'Tingkat Kesatuan',
                      onTap: () => onSelect(RouteNames.units),
                    ),
                    _DataMenuItem(
                      icon: Icons.badge_rounded,
                      label: 'Jabatan',
                      onTap: () => onSelect(RouteNames.positions),
                    ),
                    _DataMenuItem(
                      icon: Icons.map_rounded,
                      label: 'Wilayah',
                      onTap: () => onSelect(RouteNames.regions),
                    ),
                    _DataMenuItem(
                      icon: Icons.local_florist_rounded,
                      label: 'Komoditi Lahan',
                      onTap: () => onSelect(RouteNames.commodities),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DataMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _DataMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C6FDE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF7C6FDE)),
            ),
            const SizedBox(width: 14),
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
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ANIMATED CURVE BACKGROUND - OPTIMIZED
// ============================================================================

class _AnimatedCurveBackground extends StatelessWidget {
  final int currentIndex;
  final double itemWidth;
  final Color backgroundColor;

  const _AnimatedCurveBackground({
    required this.currentIndex,
    required this.itemWidth,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: currentIndex.toDouble()),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      builder: (context, value, _) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 80),
          painter: _CurvePainter(
            position: value,
            itemWidth: itemWidth,
            color: backgroundColor,
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

  _CurvePainter({
    required this.position,
    required this.itemWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final path = Path();

    // Starting point
    path.moveTo(0, 0);

    // Calculate center position of active item
    final centerX = (position * itemWidth) + (itemWidth / 2);

    // Curve parameters - REDUCED HEIGHT
    const curveDepth = 22.0; // Dikurangi dari 35 menjadi 22
    final curveWidth = itemWidth * 0.75; // Dikurangi dari 0.85
    final curveStart = centerX - (curveWidth / 2);
    final curveEnd = centerX + (curveWidth / 2);

    // Lead-in curve (smooth transition to dip)
    final leadInStart = curveStart - 16;

    // Draw path from left
    path.lineTo(leadInStart, 0);

    // Smooth curve down to dip
    path.cubicTo(
      leadInStart + 8,
      0,
      curveStart - 4,
      -curveDepth * 0.3,
      curveStart,
      -curveDepth * 0.6,
    );

    // Deep curve at center
    path.cubicTo(
      curveStart + (curveWidth * 0.25),
      -curveDepth,
      curveEnd - (curveWidth * 0.25),
      -curveDepth,
      curveEnd,
      -curveDepth * 0.6,
    );

    // Smooth curve back up
    path.cubicTo(
      curveEnd + 4,
      -curveDepth * 0.3,
      curveEnd + 8,
      0,
      curveEnd + 16,
      0,
    );

    // Complete the path
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.06), 4, true);

    // Draw main path
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
      oldDelegate.position != position;
}

// ============================================================================
// NAVBAR ITEM - OPTIMIZED
// ============================================================================

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
              top:
                  isSelected ? 8 : 24, // Adjusted untuk curve yang lebih rendah
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    padding: EdgeInsets.all(isSelected ? 13 : 0),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                  spreadRadius: -2,
                                ),
                              ]
                              : [],
                    ),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      size: isSelected ? 26 : 24,
                      color: isSelected ? Colors.white : inactiveColor,
                    ),
                  ),
                  SizedBox(height: isSelected ? 6 : 4),
                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    style: TextStyle(
                      fontSize: isSelected ? 11 : 10,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? primaryColor : inactiveColor,
                      letterSpacing: isSelected ? 0.2 : 0,
                    ),
                    child: Text(label),
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
