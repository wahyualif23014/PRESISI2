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
import '../features/admin/main_data/commodities/comodities.dart';

// ===== LAND MANAGEMENT =====
import '../features/admin/land_management/land_shell_page.dart';
import '../features/admin/land_management/overview/overview_page.dart';
import '../features/admin/land_management/plots/plots_page.dart';
import '../features/admin/land_management/crops/crops_page.dart';

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
      // =========================
      // AUTH ROUTES
      // =========================
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

      // =========================
      // MAIN SHELL (BOTTOM NAV)
      // =========================
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

          // =====================================================
          // MAIN DATA SHELL
          // =====================================================
          ShellRoute(
            builder: (context, state, child) {
              return MainDataShellPage(child: child);
            },
            routes: [
              GoRoute(
                path: RouteNames.data,
                redirect: (_, __) => RouteNames.dataUnits,
              ),
              GoRoute(
                path: RouteNames.dataUnits,
                pageBuilder:
                    (_, __) => NoTransitionPage(child: UnitsPage()),
              ),
              GoRoute(
                path: RouteNames.dataPositions,
                pageBuilder:
                    (_, __) => NoTransitionPage(child: PositionPage()),
              ),
              GoRoute(
                path: RouteNames.dataRegions,
                pageBuilder:
                    (_, __) => NoTransitionPage(child: RegionsPage()),
              ),
              GoRoute(
                path: RouteNames.dataCommodities,
                pageBuilder:
                    (_, __) => NoTransitionPage(child: ComoditiesPage()),
              ),
            ],
          ),

          // =====================================================
          // LAND MANAGEMENT SHELL
          // =====================================================
          ShellRoute(
            builder: (context, state, child) {
              return LandShellPage(child: child);
            },
            routes: [
              GoRoute(
                path: RouteNames.landManagement,
                redirect: (_, __) => RouteNames.landOverview,
              ),
              GoRoute(
                path: RouteNames.landOverview,
                pageBuilder:
                    (_, __) => NoTransitionPage(child: OverviewPage()),
              ),
              GoRoute(
                path: RouteNames.landPlots,
                pageBuilder:
                    (_, __) => NoTransitionPage(child: PlotsPage()),
              ),
              GoRoute(
                path: RouteNames.landCrops,
                pageBuilder:
                    (_, __) => NoTransitionPage(child: CropsPage()),
              ),
            ],
          ),

          // ===== RECAP =====
          GoRoute(
            path: RouteNames.recap,
            pageBuilder:
                (_, __) => const NoTransitionPage(child: Datarecap()),
          ),
        ],
      ),
    ],
  );
}
