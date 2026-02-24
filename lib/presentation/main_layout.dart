import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/shared/widgets/CustomBottomNavBar.dart';
import 'package:provider/provider.dart';
import 'widgets/admin_top_bar.dart';

// --- PALET WARNA EARTHY & ORGANIC ---
const Color _forestGreen = Color(0xFF2D4F1E);
const Color _warmBeige = Color(0xFFF5E6CC);
const Color _terracotta = Color(0xFFE27D60);
const Color _slateGrey = Color(0xFF4A4A4A);
const Color _bgWarm = Color(0xFFFDF8F3);
const Color _borderWarm = Color(0xFFE8DDD0);

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  static const double _bottomNavHeight = 80.0;
  static const double _topBarHeight = 70.0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.userRole;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _bgWarm,
      
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(_topBarHeight),
        child: AdminTopBar(height: _topBarHeight),
      ),
      
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: _bgWarm,
                child: child,
              ),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: isKeyboardOpen 
        ? null 
        : Container(
            height: _bottomNavHeight,
            color: Colors.white,
            child: CustomBottomNavBar(role: role),
          ),
    );
  }
}