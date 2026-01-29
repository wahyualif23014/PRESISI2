import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

// ===== AUTH =====
import '../../auth/provider/auth_provider.dart';
import '../../auth/pages/login_screen.dart';
import '../../auth/pages/register_screen.dart';

// ===== LAYOUT =====
import '../../presentation/main_layout.dart';

// ===== DASHBOARD & MENU UTAMA =====
import '../features/admin/dashboard/presentation/dashboard_page.dart';
import '../features/admin/personnel/presentation/personel_page.dart';
import '../features/admin/recap/page_recap.dart';

// ===== MAIN DATA =====
import '../features/admin/main_data/main_data_shell_page.dart';
import '../features/admin/main_data/units/units.dart';
import '../features/admin/main_data/positions/position_page.dart';
import '../features/admin/main_data/regions/regions_page.dart';
import '../features/admin/main_data/commodities/comodities_page.dart';

// ===== LAND MANAGEMENT =====
import '../features/admin/land_management/land_shell_page.dart';
import '../features/admin/land_management/Potensi_lahan/potensi_page.dart';
import '../features/admin/land_management/kelola_lahan/Kelola_lahan_page.dart';
import '../features/admin/land_management/riwayat_lahan/riwayat_lahan_page.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  static final _rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );

  static final _shellNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'shell',
  );

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.dashboard,
    refreshListenable: authProvider,

    // =========================
    // AUTH REDIRECT
    // =========================
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuth;
      final isLoading = authProvider.isLoading;

      if (isLoading) return null;

      final location = state.matchedLocation;
      final isAuthRoute =
          location == RouteNames.login || location == RouteNames.register;

      if (!isLoggedIn) {
        return isAuthRoute ? null : RouteNames.login;
      }

      if (isLoggedIn && isAuthRoute) {
        return RouteNames.dashboard;
      }

      return null;
    },

    routes: [
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
          // ===== DASHBOARD =====
          GoRoute(
            path: RouteNames.dashboard,
            pageBuilder:
                (_, __) => const NoTransitionPage(child: DashboardPage()),
          ),

          // ===== PERSONNEL =====
          GoRoute(
            path: RouteNames.personnel,
            pageBuilder:
                (_, __) => const NoTransitionPage(child: PersonelPage()),
          ),

          // ===========================================
          // MAIN DATA SHELL (PERBAIKAN DI SINI)
          // ===========================================
          ShellRoute(
            builder: (context, state, child) {
              return MainDataShellPage(child: child);
            },
            routes: [
              // 1. ROUTE ROOT DATA (/data)
              // Hapus 'redirect'. Ganti dengan pageBuilder ke halaman default (UnitsPage).
              // Ini agar saat user klik "Data", URL tetap '/data' dan ShellPage bisa mendeteksi reset menu.
              GoRoute(
                path: RouteNames.data,
                pageBuilder: (_, __) => const NoTransitionPage(child: UnitsPage()), 
              ),
              
              // 2. Sub Routes
              GoRoute(
                path: RouteNames.dataUnits,
                pageBuilder:
                    (_, __) => const NoTransitionPage(child: UnitsPage()),
              ),
              GoRoute(
                path: RouteNames.dataPositions,
                pageBuilder:
                    (_, __) => const NoTransitionPage(child: PositionPage()),
              ),
              GoRoute(
                path: RouteNames.dataRegions,
                pageBuilder:
                    (_, __) => const NoTransitionPage(child: RegionsPage()),
              ),
              GoRoute(
                path: RouteNames.dataCommodities,
                pageBuilder:
                    (_, __) => const NoTransitionPage(child: ComoditiesPage()),
              ),
            ],
          ),

          // ===========================================
          // LAND MANAGEMENT SHELL (PERBAIKAN DI SINI)
          // ===========================================
          ShellRoute(
            builder: (context, state, child) {
              return LandShellPage(child: child);
            },
            routes: [
              // 1. ROUTE ROOT LAND (/land-management)
              // Hapus 'redirect'. Ganti dengan pageBuilder ke halaman default (OverviewPage).
              GoRoute(
                path: RouteNames.landManagement,
                 pageBuilder: (_, __) => const NoTransitionPage(child: OverviewPage()),
              ),

              // 2. Sub Routes
              GoRoute(
                path: RouteNames.landOverview,
                pageBuilder:
                    (_, __) => const NoTransitionPage(child: OverviewPage()),
              ),
              GoRoute(
                path: RouteNames.landPlots,
                pageBuilder:
                    (_, __) => const NoTransitionPage(child: KelolaLahanPage()),
              ),
              GoRoute(
                path: RouteNames.landCrops,
                pageBuilder:
                    (_, __) => const NoTransitionPage(child: RiwayatKelolaLahanPage()),
              ),
            ],
          ),

          // ===== RECAP =====
          GoRoute(
            path: RouteNames.recap,
            pageBuilder:
                (_, __) => const NoTransitionPage(child: PageRecap()),
          ),
        ],
      ),
    ],
  );
}