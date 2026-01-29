import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/router/route_names.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  static const List<_NavItemModel> _navItems = [
    _NavItemModel(
      label: "Rekap",
      icon: Icons.print_outlined,
      activeIcon: Icons.print_rounded,
      route: RouteNames.recap,
    ),
    _NavItemModel(
      label: "Data",
      icon: Icons.storage_outlined,
      activeIcon: Icons.storage_rounded,
      route: RouteNames.data,
    ),
    _NavItemModel(
      label: "Beranda",
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      route: RouteNames.dashboard,
    ),
    _NavItemModel(
      label: "Lahan",
      icon: Icons.spa_outlined,
      activeIcon: Icons.spa_rounded,
      route: RouteNames.landManagement,
    ),
    _NavItemModel(
      label: "Personel",
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      route: RouteNames.personnel,
    ),
  ];

  static const double _navHeight = 80.0;

  int _calculateSelectedIndex(String location) {
    final index = _navItems.indexWhere(
      (item) => location.startsWith(item.route),
    );
    return index != -1 ? index : 2;
  }


  void _onItemTapped(BuildContext context, int index, int currentIndex) {
    context.go(_navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _calculateSelectedIndex(location);
    final itemWidth = size.width / _navItems.length;

    return SizedBox(
      height: _navHeight,
      width: size.width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _NavCurveBackground(
            currentIndex: currentIndex,
            itemWidth: itemWidth,
            height: _navHeight,
          ),
          Row(
            children: List.generate(_navItems.length, (index) {
              return _NavBarItem(
                data: _navItems[index],
                isSelected: index == currentIndex,
                width: itemWidth,
                onTap: () => _onItemTapped(context, index, currentIndex),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PRIVATE CLASSES (Model & Widgets)
// -----------------------------------------------------------------------------

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
  final double width;
  final VoidCallback onTap;

  static const Color primaryColor = Color(0xFF7C6FDE);
  static const Color inactiveColor = Color(0xFF94A3B8);

  const _NavBarItem({
    required this.data,
    required this.isSelected,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              top: isSelected ? 8 : 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconContainer(),
                  const SizedBox(height: 6),
                  _buildLabel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.all(isSelected ? 12 : 0),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Icon(
        isSelected ? data.activeIcon : data.icon,
        size: 24,
        color: isSelected ? Colors.white : inactiveColor,
      ),
    );
  }

  Widget _buildLabel() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: 1.0,
      child: Text(
        data.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? primaryColor : inactiveColor,
          letterSpacing: 0.3,
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: currentIndex.toDouble()),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
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
    final centerX = (position * itemWidth) + (itemWidth / 2);

    const curveDepth = 22.0;
    final curveWidth = itemWidth * 0.75;
    final curveStart = centerX - (curveWidth / 2);
    final curveEnd = centerX + (curveWidth / 2);

    path.moveTo(0, 0);
    path.lineTo(curveStart - 20, 0);

    path.cubicTo(
      curveStart - 5,
      0,
      curveStart + 5,
      -curveDepth,
      centerX,
      -curveDepth,
    );

    path.cubicTo(curveEnd - 5, -curveDepth, curveEnd + 5, 0, curveEnd + 20, 0);

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.15), 8, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NavCurvePainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.itemWidth != itemWidth ||
        oldDelegate.color != color;
  }
}