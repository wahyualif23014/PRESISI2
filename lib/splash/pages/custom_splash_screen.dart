import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../router/route_names.dart';
import '../../../../auth/provider/auth_provider.dart';

// Ganti import ini dengan path AppColors Anda
// import '../../../../core/theme/app_colors.dart'; 

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Animasi Jatuh: Dari atas layar (-500) ke posisi 0 (Tengah)
    _bounceAnimation = Tween<double>(begin: -600, end: 0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.bounceOut,
      ),
    );

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Animasi Scale: Dari ukuran normal 1x menjadi sangat besar 35x
    _expandAnimation = Tween<double>(begin: 1.0, end: 35.0).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: Curves.easeInOut,
      ),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    await _bounceController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _expandController.forward();
    await _logoController.forward();
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuth) {
        context.go(RouteNames.dashboard);
      } else {
        context.go(RouteNames.login);
      }
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _expandController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hardcode warna agar tidak perlu import AppColors jika belum ada
    const Color greenLight = Color(0xFF4ADE80);
    const Color orangeAccent = Color(0xFFF97316);

    const List<Color> gradientColors = [greenLight, orangeAccent];

    // Menggunakan LayoutBuilder agar ukuran layar didapat secara dinamis
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        
        // Ukuran bola awal (misal 100x100)
        const double ballSize = 100;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            // Stack Fit Expand memastikan children bisa memenuhi layar
            fit: StackFit.expand,
            alignment: Alignment.center, // Kunci agar default child di tengah
            children: [
              
              // LAYER 1: BOLA ANIMASI
              AnimatedBuilder(
                animation: Listenable.merge([_bounceController, _expandController]),
                builder: (context, child) {
                  // Hitung Translation Y
                  // Jika value -600 (awal), bola di atas layar.
                  // Jika value 0 (akhir), bola di tengah layar.
                  final double translationY = _bounceAnimation.value;
                  
                  final double scale = _expandAnimation.value;

                  return Transform.translate(
                    offset: Offset(0, translationY),
                    child: Transform.scale(
                      scale: scale,
                      child: Center( // Center memastikan Container tetap di tengah sebelum transform
                        child: Container(
                          width: ballSize,
                          height: ballSize,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradientColors,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // LAYER 2: KONTEN (LOGO & TEXT)
              // Center Widget digunakan untuk memastikan konten benar-benar di tengah
              Center(
                child: FadeTransition(
                  opacity: _logoAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Vertical Center
                    crossAxisAlignment: CrossAxisAlignment.center, // Horizontal Center
                    mainAxisSize: MainAxisSize.min, // Agar column setinggi konten saja
                    children: [
                      Image.asset(
                        'assets/image/logo.png',
                        width: screenWidth * 0.4, // Lebar logo responsif (40% lebar layar)
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "SIKAP PRESISI",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4.0,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "SISTEM KETAHANAN PANGAN\nPOLDA JAWA TIMUR",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // LAYER 3: VERSI (Di Bawah)
              Positioned(
                bottom: 40,
                left: 0, 
                right: 0,
                child: FadeTransition(
                  opacity: _logoAnimation,
                  child: const Center(
                    child: Text(
                      "Versi 2.30",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}