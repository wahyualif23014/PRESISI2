import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/router/route_names.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  bool _isDataOpen = false;
  bool _openDataAfterNavigate = false;

  void _toggleData() {
    setState(() => _isDataOpen = !_isDataOpen);
  }

  void _closeData() {
    if (_isDataOpen) {
      setState(() => _isDataOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final location = GoRouterState.of(context).uri.toString();

    /// 🔥 AUTO OPEN POPUP SETELAH NAVIGASI KE DATA
    if (_openDataAfterNavigate && location == RouteNames.data) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isDataOpen = true;
            _openDataAfterNavigate = false;
          });
        }
      });
    }

    const primaryColor = Color(0xFF7C6FDE);
    const inactiveColor = Color(0xFF94A3B8);
    const backgroundColor = Colors.white;

    final itemWidth = size.width / 5;

    /// 🔒 Jika popup data terbuka → index dikunci ke Data
    final currentIndex = _isDataOpen ? 1 : _getCurrentIndex(location);

    return SizedBox(
      width: size.width,
      height: _isDataOpen ? 320 : 100,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // =====================================================
          // OVERLAY (TAP LUAR → TUTUP POPUP)
          // =====================================================
          if (_isDataOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeData,
                child: const SizedBox(),
              ),
            ),

          // =====================================================
          // POPUP DATA (CENTER & PROFESSIONAL)
          // =====================================================
          if (_isDataOpen)
            Positioned(
              bottom: 120,
              left: (size.width / 2) - 100, // popupWidth / 2
              child: _DataPopup(
                itemWidth: itemWidth,
                onSelect: (route) {
                  _closeData();
                  context.go(route);
                },
              ),
            ),

          // =====================================================
          // CURVE BACKGROUND
          // =====================================================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: _AnimatedCurveBackground(
              currentIndex: currentIndex,
              itemWidth: itemWidth,
              backgroundColor: backgroundColor,
            ),
          ),

          // =====================================================
          // NAVBAR ITEMS
          // =====================================================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Row(
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
                  onTap: () {
                    _closeData();
                    context.go(RouteNames.recap);
                  },
                ),

                // ================= DATA =================
                _NavBarItem(
                  index: 1,
                  currentIndex: currentIndex,
                  width: itemWidth,
                  label: "Data",
                  icon: Icons.storage_outlined,
                  activeIcon: Icons.storage_rounded,
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                  onTap: () {
                    if (_isOnData(location)) {
                      _toggleData();
                    } else {
                      _openDataAfterNavigate = true;
                      context.go(RouteNames.data);
                    }
                  },
                ),

                _NavBarItem(
                  index: 2,
                  currentIndex: currentIndex,
                  width: itemWidth,
                  label: "Beranda",
                  icon: Icons.beach_access_outlined,
                  activeIcon: Icons.beach_access_rounded,
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                  onTap: () {
                    _closeData();
                    context.go(RouteNames.dashboard);
                  },
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
                  onTap: () {
                    _closeData();
                    context.go(RouteNames.landManagement);
                  },
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
                  onTap: () {
                    _closeData();
                    context.go(RouteNames.personnel);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // ROUTE → INDEX
  // ===========================================================
  int _getCurrentIndex(String location) {
    if (location == RouteNames.recap) return 0;
    if (_isOnData(location)) return 1;
    if (location == RouteNames.dashboard) return 2;
    if (location.startsWith('/land')) return 3;
    if (location.startsWith('/personnel')) return 4;
    return 2;
  }

  bool _isOnData(String location) {
    return location == RouteNames.data ||
        location.startsWith('/units') ||
        location.startsWith('/positions') ||
        location.startsWith('/regions') ||
        location.startsWith('/commodities');
  }
}

// ============================================================================
// POPUP DATA
// ============================================================================
class _DataPopup extends StatelessWidget {
  final double itemWidth;
  final Function(String route) onSelect;

  const _DataPopup({required this.itemWidth, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const popupWidth = 200.0;

    return Container(
      width: popupWidth,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DataItem(
            icon: Icons.account_tree,
            label: 'Tingkat Kesatuan',
            onTap: () => onSelect(RouteNames.units),
          ),
          _DataItem(
            icon: Icons.badge,
            label: 'Jabatan',
            onTap: () => onSelect(RouteNames.positions),
          ),
          _DataItem(
            icon: Icons.map,
            label: 'Wilayah',
            onTap: () => onSelect(RouteNames.regions),
          ),
          _DataItem(
            icon: Icons.local_florist,
            label: 'Komoditi Lahan',
            onTap: () => onSelect(RouteNames.commodities),
          ),
        ],
      ),
    );
  }
}

class _DataItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DataItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF7C6FDE)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CURVE BACKGROUND
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      builder: (_, value, __) {
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
    final paint = Paint()..color = color;
    final path = Path()..moveTo(0, 0);

    final loc = (position * itemWidth) + (itemWidth / 2);
    final curveWidth = itemWidth * 0.85;

    path.lineTo(loc - (curveWidth / 2) - 20, 0);

    path.cubicTo(
      loc - (curveWidth / 2.5),
      0,
      loc - (curveWidth / 3),
      -35,
      loc,
      -35,
    );

    path.cubicTo(
      loc + (curveWidth / 3),
      -35,
      loc + (curveWidth / 2.5),
      0,
      loc + (curveWidth / 2) + 20,
      0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.04), 6, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
      oldDelegate.position != position;
}

// ============================================================================
// NAVBAR ITEM
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
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              top: isSelected ? 10 : 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(isSelected ? 14 : 0),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      size: isSelected ? 28 : 26,
                      color: isSelected ? Colors.white : inactiveColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
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
