import 'package:KETAHANANPANGAN/splash/pages/custom_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

// Import Screen
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
    
    // 1. SET INITIAL LOCATION KE SPLASH
    initialLocation: RouteNames.splash, 
    
    refreshListenable: authProvider,

    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuth;
      final isLoading = authProvider.isLoading;
      final location = state.matchedLocation;

      // 2. JIKA SEDANG DI SPLASH, BIARKAN SAJA (JANGAN REDIRECT DULU)
      // Biarkan animasi selesai, nanti Splash Screen yang akan navigasi manual.
      if (location == RouteNames.splash) {
        return null; 
      }

      if (isLoading) return null;

      final isAuthRoute = location == RouteNames.login || location == RouteNames.register;

      if (!isLoggedIn) {
        return isAuthRoute ? null : RouteNames.login;
      }

      if (isLoggedIn && isAuthRoute) {
        return RouteNames.dashboard;
      }

      return null;
    },

    routes: [
      // 3. TAMBAHKAN ROUTE SPLASH
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const CustomSplashScreen(),
      ),

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

      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            pageBuilder: (_, __) => const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: RouteNames.personnel,
            pageBuilder: (_, __) => const NoTransitionPage(child: PersonelPage()),
          ),
          
          // MAIN DATA SHELL
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

          // LAND MANAGEMENT SHELL
          ShellRoute(
            builder: (context, state, child) => LandShellPage(child: child),
            routes: [
              GoRoute(path: RouteNames.landManagement, pageBuilder: (_, __) => const NoTransitionPage(child: OverviewPage())),
              GoRoute(path: RouteNames.landOverview, pageBuilder: (_, __) => const NoTransitionPage(child: OverviewPage())),
              GoRoute(path: RouteNames.landPlots, pageBuilder: (_, __) => const NoTransitionPage(child: KelolaLahanPage())),
              GoRoute(path: RouteNames.landCrops, pageBuilder: (_, __) => const NoTransitionPage(child: RiwayatKelolaLahanPage())),
            ],
          ),

          GoRoute(
            path: RouteNames.recap,
            pageBuilder: (_, __) => const NoTransitionPage(child: PageRecap()),
          ),
        ],
      ),
    ],
  );
}