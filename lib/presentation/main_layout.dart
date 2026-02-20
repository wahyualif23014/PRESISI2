import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/shared/widgets/CustomBottomNavBar.dart';
import 'package:provider/provider.dart';
import 'widgets/admin_top_bar.dart';

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
      // ✅ FIX: extendBody dihapus untuk menghindari konflik constraint
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),
      
      // AppBar di atas
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(_topBarHeight),
        child: AdminTopBar(height: _topBarHeight),
      ),
      
      // ✅ FIX: Body dengan constraint yang jelas menggunakan SafeArea
      body: SafeArea(
        bottom: false, // Biar body extend sampai bawah (tapi tidak conflict dengan navbar)
        child: Column(
          children: [
            // Content area dengan Expanded untuk constraint yang valid
            Expanded(
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: child, // Child di sini dengan constraint dari Expanded
              ),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: isKeyboardOpen 
        ? null 
        : Container(
            height: _bottomNavHeight,
            color: Colors.white, // Background putih untuk navbar
            child: CustomBottomNavBar(role: role),
          ),
    );
  }
}