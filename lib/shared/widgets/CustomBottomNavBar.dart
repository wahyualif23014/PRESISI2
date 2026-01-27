import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/router/route_names.dart';

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  static const double _navHeight = 80;

  static const List<_NavItemData> _navItems = [
    _NavItemData(
      label: "Rekap",
      icon: Icons.print_outlined,
      activeIcon: Icons.print_rounded,
      route: RouteNames.recap,
    ),
    _NavItemData(
      label: "Data",
      icon: Icons.storage_outlined,
      activeIcon: Icons.storage_rounded,
      route: RouteNames.data,
    ),
    _NavItemData(
      label: "Beranda",
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      route: RouteNames.dashboard,
    ),
    _NavItemData(
      label: "Lahan",
      icon: Icons.spa_outlined,
      activeIcon: Icons.spa_rounded,
      route: RouteNames.landManagement,
    ),
    _NavItemData(
      label: "Personel",
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      route: RouteNames.personnel,
    ),
  ];

  int _getCurrentIndex(String location) {
    final index = _navItems.indexWhere(
      (item) => location.startsWith(item.route),
    );
    return index != -1 ? index : 2;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _getCurrentIndex(location);
    final itemWidth = size.width / _navItems.length;

    return SizedBox(
      height: _navHeight,
      width: size.width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _AnimatedCurveBackground(
            currentIndex: currentIndex,
            itemWidth: itemWidth,
            totalItems: _navItems.length,
          ),
          Row(
            children:
                _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return _NavBarItem(
                    index: index,
                    currentIndex: currentIndex,
                    width: itemWidth,
                    data: item,
                    onTap: () {
                      if (index != currentIndex) {
                        context.go(item.route);
                      }
                    },
                  );
                }).toList(),
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
  final _NavItemData data;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.index,
    required this.currentIndex,
    required this.width,
    required this.data,
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.all(isSelected ? 12 : 0),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow:
                          isSelected
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
                  ),
                  const SizedBox(height: 6),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: 1.0,
                    child: Text(
                      data.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? primaryColor : inactiveColor,
                        letterSpacing: 0.3,
                      ),
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
  final int totalItems;

  const _AnimatedCurveBackground({
    required this.currentIndex,
    required this.itemWidth,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: currentIndex.toDouble()),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 80),
          painter: _CurvePainter(
            position: value,
            itemWidth: itemWidth,
            color: Colors.white,
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

    // Hitung posisi tengah kurva
    final centerX = (position * itemWidth) + (itemWidth / 2);

    // Konfigurasi Lekukan Tengah (Navigasi)
    const curveDepth = 22.0;
    final curveWidth = itemWidth * 0.75;
    final curveStart = centerX - (curveWidth / 2);
    final curveEnd = centerX + (curveWidth / 2);

    path.moveTo(0, 0);

    // 2. Garis lurus menuju awal lekukan navigasi
    path.lineTo(curveStart - 20, 0);

    path.cubicTo(
      curveStart - 5,
      0,
      curveStart + 5,
      -curveDepth, // Control point 2
      centerX,
      -curveDepth, // Titik tengah
    );

    path.cubicTo(
      curveEnd - 5,
      -curveDepth, // Control point 3
      curveEnd + 5,
      0, // Control point 4
      curveEnd + 20,
      0, // Titik akhir kurva
    );

    // 4. Lanjut lurus ke Titik Lebar Penuh, 0 (Pojok Kanan Atas Tajam)
    path.lineTo(size.width, 0);

    // 5. Tutup Path ke bawah
    path.lineTo(size.width, size.height); // Kanan Bawah
    path.lineTo(0, size.height); // Kiri Bawah
    path.close();

    // Gambar Shadow dan Path
    canvas.drawShadow(path, Colors.black.withOpacity(0.15), 8, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.itemWidth != itemWidth ||
        oldDelegate.color != color;
  }
}
