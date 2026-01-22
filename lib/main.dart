import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider Lama
import 'package:flutter_riverpod/flutter_riverpod.dart'; // TAMBAHAN: Riverpod
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import File Anda
import 'auth/provider/auth_provider.dart';
import './router/router_provider.dart';

import 'features/admin/dashboard/providers/dashboard_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Setup Tanggal
  await initializeDateFormatting('id_ID');
  
  // 2. Setup Supabase
  await Supabase.initialize(
    url: 'https://hbrcteaygmjrzwjyuzje.supabase.co',
    anonKey: 'sb_publishable_iSnXoF0gzV6j3A4-ynRwwQ_ck5tg477',
  );

  // 3. Setup Auth Provider (Legacy/Existing)
  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();

  // 4. Setup Router
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

      // Konfigurasi Router
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

      // Error Handling yang Aman
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
  fontFamily: 'Ramabhadra',
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