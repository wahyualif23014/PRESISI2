import 'package:KETAHANANPANGAN/features/admin/main_data/regions/data/provider/region_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/providers/unit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- IMPORTS ---
import 'auth/provider/auth_provider.dart';
import './router/router_provider.dart';
import 'features/admin/dashboard/providers/dashboard_provider.dart';
import 'features/admin/personnel/providers/personel_provider.dart'; // [NEW] Import PersonelProvider

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Setup Date Format (Indonesia)
  await initializeDateFormatting('id_ID');

  // 2. Initialize Auth & Check Login Status
  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();

  // 3. Setup Router with Redirect Logic
  final appRouter = AppRouter(authProvider);

  // 4. Run App
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => PersonelProvider()),
        ChangeNotifierProvider(create: (_) => UnitProvider()),
        ChangeNotifierProvider(create: (_) => RegionProvider()),
      ],
      child: MyApp(appRouter: appRouter),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistem Ketahanan Pangan Presisi',
      debugShowCheckedModeBanner: false,

      // Router Config
      routerConfig: appRouter.router,

      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),

      // Theme
      theme: _lightTheme,
      themeMode: ThemeMode.light,

      // Global Error Builder
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          // Pass the actual error message to the view
          return _SafeErrorView(errorMessage: details.exceptionAsString());
        };
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

// --- THEME CONFIGURATION ---
final ThemeData _lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Ramabhadra',
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF00A7C4), // Consistent with your UI color
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

// --- SAFE ERROR VIEW (DEBUG MODE) ---
class _SafeErrorView extends StatelessWidget {
  final String? errorMessage;

  const _SafeErrorView({this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Terjadi Kesalahan Aplikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Show actual error only in debug mode usually, but helpful for you now
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage ?? 'Unknown Error',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontFamily: 'Courier', // Monospace for code font
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}