import 'package:KETAHANANPANGAN/auth/models/role_enum.dart';

class RouteNames {
  RouteNames._();

  // --- AUTH ---
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register'; 

  // --- CORE ---
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  
  // --- DATA UTAMA (ADMIN ONLY) ---
  static const String data = '/data';
  static const String dataUnits = '/data/units';
  static const String dataPositions = '/data/positions';
  static const String dataRegions = '/data/regions';
  static const String dataCommodities = '/data/commodities';

  // --- MANAJEMEN LAHAN ---
  static const String landManagement = '/land-management';
  static const String landOverview = '/land-management/overview';
  static const String landPlots = '/land-management/plots';
  static const String landCrops = '/land-management/crops';

  // --- MENU LAINNYA ---
  static const String personnel = '/personnel';
  static const String recap = '/recap';

  // HELPER METHODS - Route Validation
  
  /// Route yang hanya bisa diakses Admin
  static final List<String> _adminOnlyRoutes = [
    personnel,
    data,
    dataUnits,
    dataPositions,
    dataRegions,
    dataCommodities,
  ];

  static final List<String> _operatorAndAbove = [
    landManagement,
    landOverview,
    landPlots,
    landCrops,
  ];

  /// Cek apakah route adalah admin only
  static bool isAdminOnly(String route) {
    return _adminOnlyRoutes.any((r) => route.startsWith(r));
  }

  /// Cek apakah route memerlukan minimal Operator
  static bool requiresOperator(String route) {
    return _operatorAndAbove.any((r) => route.startsWith(r));
  }

  /// Cek apakah route valid untuk role tertentu
  static bool isAllowedForRole(String route, UserRole role) {
    switch (role) {
      case UserRole.admin:
        return true;
      case UserRole.operator:
        return !isAdminOnly(route);
      case UserRole.view:
      default:
        return !isAdminOnly(route) && !requiresOperator(route);
    }
  }

  static bool isLandRoute(String route) {
    return route.startsWith(landManagement);
  }

  /// ✅ STEP 3.2: Get land route type untuk operator navbar
  static LandRouteType? getLandRouteType(String route) {
    if (route == landOverview) return LandRouteType.overview;
    if (route == landPlots) return LandRouteType.plots;
    if (route == landCrops) return LandRouteType.crops;
    return null;
  }
}

/// ✅ Helper enum untuk land routes
enum LandRouteType {
  overview,
  plots,
  crops,
}