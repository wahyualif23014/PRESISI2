import 'package:flutter/material.dart';

/// Kunci navigasi global agar bisa melakukan redirect (misal ke halaman Login)
/// dari lapisan yang tidak memiliki akses ke BuildContext secara langsung (seperti interceptor API).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Kunci scaffold global agar bisa menampilkan SnackBar dari mana saja.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
