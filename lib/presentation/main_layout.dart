import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/shared/widgets/CustomBottomNavBar.dart';
import 'widgets/admin_top_bar.dart'; // Import widget baru

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  static const double _bottomNavHeight = 90; // Sedikit lebih tinggi untuk estetika
  static const double _topBarHeight = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF8FAFC), 
      
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(_topBarHeight),
        child: AdminTopBar(height: _topBarHeight),
      ),
      
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Content Layer
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: _bottomNavHeight - 20), 
              child: child,
            ),
          ),

          const Positioned(
            left: 0, 
            right: 0, 
            bottom: 0, 
            child: CustomBottomNavBar()
          ),
        ],
      ),
    );
  }
}