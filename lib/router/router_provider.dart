import 'package:KETAHANANPANGAN/splash/pages/custom_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

// Import Provider & Screens
import '../../auth/provider/auth_provider.dart';
import '../../auth/pages/login_screen.dart';
import '../../auth/pages/register_screen.dart';
import '../../presentation/main_layout.dart';

// Import Feature Pages
import '../../features/admin/dashboard/presentation/dashboard_page.dart';
import '../../features/admin/personnel/presentation/personel_page.dart';
import '../../features/admin/recap/page_recap.dart';
import '../../features/admin/main_data/main_data_shell_page.dart';
import '../../features/admin/main_data/units/units.dart';
import '../../features/admin/main_data/positions/position_page.dart';
import '../../features/admin/main_data/regions/regions_page.dart';
import '../../features/admin/main_data/commodities/comodities_page.dart';
import '../../features/admin/land_management/land_shell_page.dart';
import '../../features/admin/land_management/Potensi_lahan/potensi_page.dart';
import '../../features/admin/land_management/kelola_lahan/Kelola_lahan_page.dart';
import '../../features/admin/land_management/riwayat_lahan/riwayat_lahan_page.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  static final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    
    // 1. Initial Location tetap Splash
    initialLocation: RouteNames.splash, 
    
    // 2. Dengarkan perubahan di AuthProvider (Login/Logout)
    refreshListenable: authProvider,

    // 3. Logic Redirect (Penjaga Pintu)
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final location = state.matchedLocation;

      // A. LOGIC SPLASH SCREEN (PENTING)
      // Jika sedang di Splash Screen, JANGAN redirect apapun.
      // Biarkan Splash Screen menyelesaikan animasinya sendiri, 
      // lalu Splash Screen yang akan memanggil context.go() secara manual.
      if (location == RouteNames.splash) {
        return null; 
      }

      // Cek apakah user sedang berada di halaman Login atau Register
      final isAuthRoute = location == RouteNames.login || location == RouteNames.register;

      // B. JIKA SUDAH LOGIN (Logic yang Anda Minta)
      if (isLoggedIn) {
        // Jika user sudah login, TAPI user berada di halaman Login/Register
        // Maka PAKSA arahkan ke Dashboard
        if (isAuthRoute) {
          return RouteNames.dashboard;
        }
        // Jika user sudah login dan berada di halaman lain (dashboard dll), biarkan.
        return null;
      }

      // C. JIKA BELUM LOGIN
      if (!isLoggedIn) {
        // Jika user belum login, dan mencoba mengakses halaman selain Login/Register/Splash
        // Maka PAKSA arahkan ke Login
        if (!isAuthRoute) {
          return RouteNames.login;
        }
        // Jika user memang di halaman login/register, biarkan.
        return null;
      }

      return null;
    },

    routes: [
      // --- SPLASH SCREEN ---
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const CustomSplashScreen(),
      ),

      // --- AUTH ROUTES ---
      GoRoute(
        path: RouteNames.login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const RegisterScreen(),
      ),

      // --- MAIN APP SHELL (Bottom Navbar / Sidebar) ---
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          // 1. Dashboard
          GoRoute(
            path: RouteNames.dashboard,
            pageBuilder: (_, __) => const NoTransitionPage(child: DashboardPage()),
          ),
          
          // 2. Personel
          GoRoute(
            path: RouteNames.personnel,
            pageBuilder: (_, __) => const NoTransitionPage(child: PersonelPage()),
          ),
          
          // 3. Data Utama (Nested Shell)
          ShellRoute(
            builder: (context, state, child) => MainDataShellPage(child: child),
            routes: [
              GoRoute(path: RouteNames.data, pageBuilder: (_, __) => const NoTransitionPage(child: UnitsPage())),
              GoRoute(path: RouteNames.dataUnits, pageBuilder: (_, __) => const NoTransitionPage(child: UnitsPage())),
              GoRoute(path: RouteNames.dataPositions, pageBuilder: (_, __) => const NoTransitionPage(child: PositionPage())),
              GoRoute(path: RouteNames.dataRegions, pageBuilder: (_, __) => const NoTransitionPage(child: RegionsPage())),
              GoRoute(path: RouteNames.dataCommodities, pageBuilder: (_, __) => const NoTransitionPage(child: ComoditiesPage())),
            ],
          ),

          // 4. Manajemen Lahan (Nested Shell)
          ShellRoute(
            builder: (context, state, child) => LandShellPage(child: child),
            routes: [
              GoRoute(path: RouteNames.landManagement, pageBuilder: (_, __) => const NoTransitionPage(child: OverviewPage())),
              GoRoute(path: RouteNames.landOverview, pageBuilder: (_, __) => const NoTransitionPage(child: OverviewPage())),
              GoRoute(path: RouteNames.landPlots, pageBuilder: (_, __) => const NoTransitionPage(child: KelolaLahanPage())),
              GoRoute(path: RouteNames.landCrops, pageBuilder: (_, __) => const NoTransitionPage(child: RiwayatKelolaLahanPage())),
            ],
          ),

          // 5. Rekap
          GoRoute(
            path: RouteNames.recap,
            pageBuilder: (_, __) => const NoTransitionPage(child: PageRecap()),
          ),
        ],
      ),
    ],
  );
}