import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sdmapp/features/admin/land_management/page_lahan.dart';
import 'package:sdmapp/features/admin/main_data/page_data.dart';
import 'package:sdmapp/features/admin/personnel/presentation/personel_page.dart';
import 'route_names.dart';

// Import Auth
import '../../auth/provider/auth_provider.dart';
import '../../auth/pages/login_screen.dart';
import '../../auth/pages/register_screen.dart';

// Import Dashboard & Layout
// Pastikan path ini sesuai dengan folder Anda
import '../features/admin/dashboard/presentation/dashboard_page.dart';
import '../../presentation/main_layout.dart';
import '../../features/admin/recap/page_recap.dart';

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

    // --- Logic Redirect ---
    redirect: (context, state) {
      final bool isLoggedIn = authProvider.isAuth;
      final bool isLoading = authProvider.isLoading;

      // Tunggu loading selesai
      if (isLoading) return null;

      final String location = state.matchedLocation;
      final bool isAuthRoute =
          location == RouteNames.login || location == RouteNames.register;

      // Belum Login -> Arahkan ke Login (kecuali sedang di halaman auth)
      if (!isLoggedIn) {
        return isAuthRoute ? null : RouteNames.login;
      }

      // Sudah Login -> Jika buka halaman auth, lempar ke Dashboard
      if (isLoggedIn && isAuthRoute) {
        return RouteNames.dashboard;
      }

      return null;
    },

    routes: [
      // 1. Login
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      // 2. Register
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // 3. Shell Route (Halaman dalam Layout)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            name: 'dashboard',
            pageBuilder:
                (context, state) => const NoTransitionPage(
                  child: DashboardPage(), // Memanggil Dashboard asli
                ),
          ),

          GoRoute(
            path: RouteNames.units,
            pageBuilder:
                (_, __) => const NoTransitionPage(
                  child: Scaffold(body: Center(child: Text("Units"))),
                ),
          ),
          GoRoute(
            path: RouteNames.personnel,
            pageBuilder:
                (_, __) => const NoTransitionPage(child: PersonelPage()),
          ),
          GoRoute(
            path: RouteNames.landManagement,
            pageBuilder:
                (_, __) => const NoTransitionPage(
                  child: Scaffold(body: Center(child: KelolaLahan())),
                ),
          ),
          GoRoute(
            path: RouteNames.recap,
            pageBuilder:
                (_, __) => const NoTransitionPage(
                  child: Scaffold(body: Center(child: Datarecap())),
                ),
          ),
          GoRoute(
            path: RouteNames.data,
            pageBuilder:
                (_, __) => const NoTransitionPage(
                  child: Scaffold(body: Center(child: DataPage())),
                ),
          ),
        ],
      ),
    ],
  );
}
