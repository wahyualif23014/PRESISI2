import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/models/role_enum.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:KETAHANANPANGAN/router/route_names.dart';
import 'package:KETAHANANPANGAN/shared/widgets/menu_provider.dart';
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
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    // ✅ Pantau State dari Provider
    final menuProvider = context.watch<MenuProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final isAdmin = authProvider.userRole == UserRole.admin;
    final isInLandSection = RouteNames.isLandRoute(location);

    // ✅ Menu muncul jika Admin, di section lahan, dan status Provider aktif
    final showMenu = isAdmin && isInLandSection && menuProvider.isLandMenuOpen;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          
          if (showMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => context.read<MenuProvider>().toggleLandMenu(false),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, _) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3.0 * value, sigmaY: 3.0 * value),
                      child: Container(
                        color: Colors.black.withOpacity(0.2 * value),
                      ),
                    );
                  },
                ),
              ),
            ),
          
          if (showMenu)
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: LandSubBottomNav(
                  onClose: () => context.read<MenuProvider>().toggleLandMenu(false),
                ),
              ),
            ),
        ],
      ),
    );
  }
}