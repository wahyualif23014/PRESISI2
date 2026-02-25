import 'package:KETAHANANPANGAN/features/operator/dashboard/presentation/operator_dashboard_page.dart' show OperatorDashboardPage;
import 'package:KETAHANANPANGAN/features/view/dashboard/presentation/dashboard_page.dart' show ViewerDashboardPage;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

// --- AUTH & CORE ---
import '../../auth/provider/auth_provider.dart';
import '../../auth/models/role_enum.dart'; 
import '../../auth/pages/login_screen.dart';
import '../../presentation/main_layout.dart';
import '../../presentation/profile/profile_page.dart';
import '../../splash/pages/custom_splash_screen.dart';

// --- FEATURE PAGES ---
import '../../features/admin/dashboard/presentation/dashboard_page.dart' as admin;
import '../../features/admin/personnel/presentation/personel_page.dart';
import '../../features/admin/recap/page_recap.dart';
import '../../features/admin/main_data/units/units.dart';
import '../../features/admin/main_data/positions/position_page.dart';
import '../../features/admin/main_data/regions/regions_page.dart';
import '../../features/admin/main_data/commodities/presentation/pages/comodities_page.dart';
import '../../features/admin/main_data/main_data_shell_page.dart';
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
    debugLogDiagnostics: true,

    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final role = authProvider.userRole;
      final location = state.matchedLocation;

      if (location == RouteNames.splash) return null;

      final isAuthRoute = location == RouteNames.login || 
                          location == RouteNames.register;

      if (!isLoggedIn) {
        return isAuthRoute ? null : RouteNames.login;
      }

      if (isAuthRoute) {
        return RouteNames.dashboard;
      }

      if (!RouteNames.isAllowedForRole(location, role)) {
        return RouteNames.dashboard;
      }

      return null;
    },

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route tidak ditemukan: ${state.uri.path}'),
      ),
    ),

    routes: [
      // --- SPLASH & LOGIN ---
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const CustomSplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const LoginScreen(),
      ),

      // --- MAIN APP SHELL ---
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          
          // DASHBOARD
          GoRoute(
            path: RouteNames.dashboard,
            name: RouteNames.dashboard,
            pageBuilder: (context, state) {
              final role = authProvider.userRole;
              switch (role) {
                case UserRole.admin:
                  return NoTransitionPage(child: admin.DashboardPage());
                case UserRole.operator:
                  return const NoTransitionPage(child: OperatorDashboardPage());
                case UserRole.view:
                  return const NoTransitionPage(child: ViewerDashboardPage());
                default:
                  return const NoTransitionPage(child: PageRecap());
              }
            },
          ),

          // PERSONEL
          GoRoute(
            path: RouteNames.personnel,
            name: RouteNames.personnel,
            pageBuilder: (_, __) => const NoTransitionPage(child: PersonelPage()),
          ),

          // DATA UTAMA (Shell Popup untuk Admin)
          ShellRoute(
            builder: (context, state, child) => MainDataShellPage(child: child),
            routes: [
              GoRoute(path: RouteNames.data, redirect: (_, __) => RouteNames.dataUnits),
              GoRoute(path: RouteNames.dataUnits, pageBuilder: (_, __) => const NoTransitionPage(child: UnitsPage())),
              GoRoute(path: RouteNames.dataPositions, pageBuilder: (_, __) => const NoTransitionPage(child: PositionPage())),
              GoRoute(path: RouteNames.dataRegions, pageBuilder: (_, __) => const NoTransitionPage(child: RegionsPage())),
              GoRoute(path: RouteNames.dataCommodities, pageBuilder: (_, __) => const NoTransitionPage(child: ComoditiesPage())),
            ],
          ),

          // MANAJEMEN LAHAN (Satu rute untuk semua Role)
          // Popup otomatis terfilter di dalam LandShellPage berdasarkan UserRole.admin
          ShellRoute(
            builder: (context, state, child) => LandShellPage(child: child),
            routes: [
              GoRoute(
                path: RouteNames.landManagement,
                redirect: (_, __) => RouteNames.landOverview,
              ),
              GoRoute(
                path: RouteNames.landOverview,
                name: RouteNames.landOverview, // Gunakan konstanta agar konsisten
                pageBuilder: (_, __) => const NoTransitionPage(child: OverviewPage()),
              ),
              GoRoute(
                path: RouteNames.landPlots,
                name: RouteNames.landPlots,
                pageBuilder: (_, __) => const NoTransitionPage(child: KelolaLahanPage()),
              ),
              GoRoute(
                path: RouteNames.landCrops,
                name: RouteNames.landCrops,
                pageBuilder: (_, __) => const NoTransitionPage(child: RiwayatKelolaLahanPage()),
              ),
            ],
          ),

          // REKAP
          GoRoute(
            path: RouteNames.recap,
            name: RouteNames.recap,
            pageBuilder: (_, __) => const NoTransitionPage(child: PageRecap()),
          ),
        ],
      ),

      // PROFILE
      GoRoute(
        path: RouteNames.profile,
        name: RouteNames.profile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const ProfilePage(),
      ),
    ],
  );
}