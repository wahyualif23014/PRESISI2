import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sdmapp/router/route_names.dart';
import 'widgets/land_sub_bottom_nav.dart';

class LandShellPage extends StatefulWidget {
  final Widget child;

  const LandShellPage({
    super.key,
    required this.child,
  });

  @override
  State<LandShellPage> createState() => _LandShellPageState();
}

class _LandShellPageState extends State<LandShellPage> {
  bool _showLandMenu = true;

  bool _isLandRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return location.startsWith(RouteNames.landManagement);
  }

  @override
  void didUpdateWidget(covariant LandShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_showLandMenu) {
      setState(() {
        _showLandMenu = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandRoute = _isLandRoute(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Stack(
        children: [
          // ================= CONTENT =================
          Padding(
            padding: EdgeInsets.only(
              bottom: isLandRoute && _showLandMenu ? 140 : 0,
            ),
            child: widget.child,
          ),

          // ================= LAND POPUP MENU =================
          if (isLandRoute && _showLandMenu)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: LandSubBottomNav(
                onClose: () {
                  setState(() {
                    _showLandMenu = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
