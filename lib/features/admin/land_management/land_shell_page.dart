import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/models/role_enum.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:KETAHANANPANGAN/router/route_names.dart';
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
  bool _isMenuManuallyClosed = false;
  String _lastLocation = '';

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    // ✅ STEP 1.1: AMBIL ROLE DARI PROVIDER
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.userRole;
    final isAdmin = role == UserRole.admin;
    
    final isLandRoot = location == RouteNames.landManagement || 
                       location == RouteNames.landOverview;

    if (location != _lastLocation) {
      if (isLandRoot) {
        _isMenuManuallyClosed = false;
      }
      _lastLocation = location;
    }

    // ✅ STEP 1.2: POPUP HANYA MUNCUL UNTUK ADMIN
    // Operator tidak akan pernah lihat popup
    final showMenu = isAdmin && isLandRoot && !_isMenuManuallyClosed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          
          if (showMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() => _isMenuManuallyClosed = true);
                },
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, _) {
                    final safeOpacity = value.clamp(0.0, 1.0);
                    
                    return BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 3.0 * safeOpacity,
                        sigmaY: 3.0 * safeOpacity,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.2 * safeOpacity),
                      ),
                    );
                  },
                ),
              ),
            ),
          
          // Layer 2: Popup Card (hanya untuk admin)
          if (showMenu)
            _buildPopupCard(),
        ],
      ),
    );
  }

  Widget _buildPopupCard() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 40, // Di atas navbar
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          final safeValue = value.clamp(0.0, 1.0);
          
          return Opacity(
            opacity: safeValue,
            child: Transform.translate(
              offset: Offset(0, 50 * (1 - safeValue)),
              child: child,
            ),
          );
        },
        child: LandSubBottomNav(
          onClose: () {
            setState(() => _isMenuManuallyClosed = true);
          },
        ),
      ),
    );
  }
}