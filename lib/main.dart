import 'package:KETAHANANPANGAN/shared/widgets/menu_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- AUTH & ROUTER ---
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:KETAHANANPANGAN/router/router_provider.dart';

// --- PROVIDERS FEATURES (Unified) ---
// Gunakan satu DashboardProvider dari folder utama/admin untuk semua role
import 'package:KETAHANANPANGAN/features/admin/dashboard/providers/dashboard_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/personnel/providers/personel_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/providers/unit_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/regions/data/provider/region_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/positions/data/providers/jabatan_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/providers/CommodityProvider.dart';

Future<void> main() async {
  // 1. Pastikan binding engine Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi format tanggal Indonesia (id_ID)
  await initializeDateFormatting('id_ID');

  // 3. Inisialisasi AuthProvider & Restore Session (Auto Login via Secure Storage)
  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();

  // 4. Inisialisasi Router dengan instance authProvider
  final appRouter = AppRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        // Master Auth & Menu
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => MenuProvider()),

        // Feature Providers (Unified)
        // Cukup panggil satu DashboardProvider untuk Admin, Operator, dan View
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        
        ChangeNotifierProvider(create: (_) => PersonelProvider()),
        ChangeNotifierProvider(create: (_) => UnitProvider()),
        ChangeNotifierProvider(create: (_) => RegionProvider()),
        ChangeNotifierProvider(create: (_) => JabatanProvider()),
        ChangeNotifierProvider(create: (_) => CommodityProvider()),
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
      title: 'Ketahanan Pangan Presisi',
      debugShowCheckedModeBanner: false,

      // Konfigurasi GoRouter
      routerConfig: appRouter.router,

      // Konfigurasi Lokalisasi (Wajib untuk format angka dan tanggal ID)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),

      // Tema Aplikasi
      theme: _appTheme,
      themeMode: ThemeMode.light,

      // Global Safe Error View
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return _SafeErrorView(errorMessage: details.exceptionAsString());
        };
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

// --- GLOBAL THEME DATA ---
final ThemeData _appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Ramabhadra',
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF10B981), // Emerald Green
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Color(0xFF1E293B), // Slate 800
    foregroundColor: Colors.white,
    centerTitle: true,
  ),
  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
);

// --- GLOBAL ERROR VIEW (UI Debugging) ---
class _SafeErrorView extends StatelessWidget {
  final String? errorMessage;
  const _SafeErrorView({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bug_report_outlined, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'Terjadi Kesalahan UI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage ?? 'Unknown error occurred',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}