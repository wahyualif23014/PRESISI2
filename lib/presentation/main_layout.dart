import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/shared/widgets/CustomBottomNavBar.dart';
import 'widgets/admin_top_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  
  const MainLayout({super.key, required this.child});

  static const double _bottomNavHeight = 90; 
  static const double _topBarHeight = 70;

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi apakah keyboard sedang aktif (terbuka)
    // Jika viewInsets.bottom > 0, berarti keyboard sedang memakan ruang di bawah
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      // extendBody: true memungkinkan konten merender di belakang navbar (transparansi)
      extendBody: true,
      // resizeToAvoidBottomInset: true memastikan konten utama mengecil saat keyboard muncul
      // agar field input tidak tertutup keyboard
      resizeToAvoidBottomInset: true, 
      backgroundColor: const Color(0xFFF8FAFC), 
      
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(_topBarHeight),
        child: AdminTopBar(height: _topBarHeight),
      ),
      
      body: Stack(
        fit: StackFit.expand,
        children: [
          // A. Content Layer (Halaman Utama)
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                // Jika keyboard terbuka, padding bawah jadi 0 agar tidak ada gap kosong
                // Jika keyboard tertutup, gunakan padding standar navbar
                bottom: isKeyboardOpen ? 0 : _bottomNavHeight - 20, 
              ), 
              child: child,
            ),
          ),

          // B. Navigation Layer (Hanya muncul jika keyboard tertutup)
          if (!isKeyboardOpen)
            const Positioned(
              left: 0, 
              right: 0, 
              bottom: 0, 
              child: CustomBottomNavBar(),
            ),
        ],
      ),
    );
  }
}