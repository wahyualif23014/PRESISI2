import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // State Management Legacy
import 'package:flutter_riverpod/flutter_riverpod.dart'; // State Management Modern
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'auth/provider/auth_provider.dart';
import './router/router_provider.dart';
import 'features/admin/dashboard/providers/dashboard_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Setup Format Tanggal (Indonesia)
  await initializeDateFormatting('id_ID');

  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();

  // 4. Setup Router (Dengan Redirect Logic)
  final appRouter = AppRouter(authProvider);

  // 5. Jalankan Aplikasi
  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),

          ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ],
        child: MyApp(appRouter: appRouter),
      ),
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

      // Konfigurasi Router (GoRouter)
      routerConfig: appRouter.router,

      // Localization (Bahasa Indonesia)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),

      // Theme Configuration
      theme: _lightTheme,
      themeMode: ThemeMode.light,
      builder: (context, child) {
        ErrorWidget.builder = (details) => const _SafeErrorView();
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

// --- CONFIG TEMA ---
final ThemeData _lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Ramabhadra', // Pastikan font terdaftar di pubspec.yaml
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.orange,
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

// --- ERROR UI AMAN ---
class _SafeErrorView extends StatelessWidget {
  const _SafeErrorView();

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
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: Colors.orange,
                ),
                SizedBox(height: 16),
                Text(
                  'Sedang Memuat Aplikasi...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
