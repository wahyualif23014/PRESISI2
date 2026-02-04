import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Import Route & Provider
import '../../router/route_names.dart';
import '../../auth/provider/auth_provider.dart';

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

    // 1. Setup Controller
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // 2. Setup Animations
    
    // Animasi Jatuh: Dari atas layar (-600) ke posisi 0 (Tengah)
    _bounceAnimation = Tween<double>(begin: -600, end: 0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.bounceOut,
      ),
    );

    // Animasi Scale: Membesar memenuhi layar (Efek transisi background)
    _expandAnimation = Tween<double>(begin: 1.0, end: 35.0).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: Curves.easeInOut,
      ),
    );

    // Animasi Fade Logo
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );

    // 3. Mulai Urutan Animasi
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Langkah 1: Bola Jatuh
    await _bounceController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Langkah 2: Bola Meledak/Expand (Jadi Background)
    await _expandController.forward();
    
    // Langkah 3: Logo Muncul
    await _logoController.forward();
    
    // Langkah 4: Tahan sebentar
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Langkah 5: Cek Status Login (Go Backend)
      // Kita menggunakan 'read' karena hanya butuh cek sekali, tidak perlu listen perubahan UI
      final auth = context.read<AuthProvider>();
      
      // Update: Menggunakan getter 'isAuthenticated' sesuai Provider baru
      if (auth.isAuthenticated) {
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
    // Warna Hardcode (Sesuai request)
    const Color greenLight = Color(0xFF4ADE80);
    const Color orangeAccent = Color(0xFFF97316); // Warna utama
    const List<Color> gradientColors = [greenLight, orangeAccent];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        // Ukuran bola awal
        const double ballSize = 100;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              
              // --- LAYER 1: BOLA ANIMASI (BACKGROUND) ---
              AnimatedBuilder(
                animation: Listenable.merge([_bounceController, _expandController]),
                builder: (context, child) {
                  final double translationY = _bounceAnimation.value;
                  final double scale = _expandAnimation.value;

                  return Transform.translate(
                    offset: Offset(0, translationY),
                    child: Transform.scale(
                      scale: scale,
                      child: Center(
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

              // --- LAYER 2: LOGO & TEXT (MUNCUL SETELAH EXPAND) ---
              Center(
                child: FadeTransition(
                  opacity: _logoAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // LOGO
                      Image.asset(
                        'assets/image/logo.png', // Pastikan path ini benar di pubspec.yaml
                        width: screenWidth * 0.35,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.shield, size: 100, color: Colors.white),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // JUDUL UTAMA
                      const Text(
                        "SIKAP PRESISI",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white, // Putih karena background sudah orange/green
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
                      
                      // SUB JUDUL
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

              // --- LAYER 3: VERSI APP ---
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