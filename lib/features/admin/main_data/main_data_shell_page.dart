import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:KETAHANANPANGAN/router/route_names.dart';
import 'widgets/main_data_sub_bottom_nav.dart';

class MainDataShellPage extends StatefulWidget {
  final Widget child;

  const MainDataShellPage({
    super.key,
    required this.child,
  });

  @override
  State<MainDataShellPage> createState() => _MainDataShellPageState();
}

class _MainDataShellPageState extends State<MainDataShellPage> {
  bool _isMenuManuallyClosed = false;
  String _lastLocation = '';

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isDataRoute = location.startsWith(RouteNames.data);

    if (location != _lastLocation) {
      if (location == RouteNames.data) {
        _isMenuManuallyClosed = false;
      }
      _lastLocation = location;
    }

    final showMenu = isDataRoute && !_isMenuManuallyClosed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: showMenu ? 140 : 0,
              ),
              child: widget.child,
            ),
          ),
          if (showMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isMenuManuallyClosed = true;
                  });
                },
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 3.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
                      child: Container(
                        color: Colors.black.withOpacity(0.2),
                      ),
                    );
                  },
                ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: showMenu ? 24 : -500,
            child: MainDataSubBottomNav(
              onClose: () {
                setState(() {
                  _isMenuManuallyClosed = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}