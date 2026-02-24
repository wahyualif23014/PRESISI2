import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/models/role_enum.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:KETAHANANPANGAN/router/route_names.dart';
import 'package:KETAHANANPANGAN/shared/widgets/menu_provider.dart';
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
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    // ✅ Pantau State dari Provider
    final menuProvider = context.watch<MenuProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final isAdmin = authProvider.userRole == UserRole.admin;
    final isDataSection = location.startsWith(RouteNames.data);

    // ✅ Menu muncul jika Admin, di section data, dan status Provider aktif
    final showMenu = isAdmin && isDataSection && menuProvider.isMainDataMenuOpen;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Content Layer
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: showMenu ? 140 : 0,
              ),
              child: widget.child,
            ),
          ),
          
          // Blur & Overlay Layer
          if (showMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => context.read<MenuProvider>().toggleMainDataMenu(false),
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
            
          // Popup Menu Layer
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 0,
            right: 0,
            bottom: showMenu ? 24 : -500,
            child: MainDataSubBottomNav(
              onClose: () => context.read<MenuProvider>().toggleMainDataMenu(false),
            ),
          ),
        ],
      ),
    );
  }
}