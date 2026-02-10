import 'package:KETAHANANPANGAN/presentation/profile/profile_page.dart';
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
    initialLocation: RouteNames.splash,
    refreshListenable: authProvider,

    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final location = state.matchedLocation;

      if (location == RouteNames.splash) return null;

      final isAuthRoute = location == RouteNames.login || location == RouteNames.register;

      if (isLoggedIn) {
        if (isAuthRoute) return RouteNames.dashboard;
        return null;
      }

      if (!isLoggedIn) {
        if (!isAuthRoute) return RouteNames.login;
        return null;
      }

      return null;
    },

    routes: [
      // --- SPLASH ---
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const CustomSplashScreen(),
      ),

      // --- AUTH ---
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const RegisterScreen(),
      ),

      // --- MAIN APP (BOTTOM NAVBAR) ---
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          // Dashboard
          GoRoute(
            path: RouteNames.dashboard,
            name: RouteNames.dashboard,
            pageBuilder: (_, __) => const NoTransitionPage(child: DashboardPage()),
          ),
          
          // Personel
          GoRoute(
            path: RouteNames.personnel,
            name: RouteNames.personnel,
            pageBuilder: (_, __) => const NoTransitionPage(child: PersonelPage()),
          ),
          
          // Data Utama (Nested)
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

          // Manajemen Lahan (Nested)
          ShellRoute(
            builder: (context, state, child) => LandShellPage(child: child),
            routes: [
              GoRoute(path: RouteNames.landManagement, pageBuilder: (_, __) => const NoTransitionPage(child: OverviewPage())),
              GoRoute(path: RouteNames.landOverview, pageBuilder: (_, __) => const NoTransitionPage(child: OverviewPage())),
              GoRoute(path: RouteNames.landPlots, pageBuilder: (_, __) => const NoTransitionPage(child: KelolaLahanPage())),
              GoRoute(path: RouteNames.landCrops, pageBuilder: (_, __) => const NoTransitionPage(child: RiwayatKelolaLahanPage())),
            ],
          ),

          // Rekap
          GoRoute(
            path: RouteNames.recap,
            name: RouteNames.recap,
            pageBuilder: (_, __) => const NoTransitionPage(child: PageRecap()),
          ),
        ],
      ),

      // --- NEW: PROFILE PAGE (Di luar ShellRoute agar Full Screen) ---
      GoRoute(
        path: RouteNames.profile,
        name: RouteNames.profile,
        parentNavigatorKey: _rootNavigatorKey, // Menutupi BottomNavbar
        builder: (_, __) => ProfilePage(),
      ),
    ],
  );
}