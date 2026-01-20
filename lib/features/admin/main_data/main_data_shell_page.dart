import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sdmapp/router/route_names.dart'; // Pastikan path benar
import 'widgets/main_data_sub_bottom_nav.dart';

class MainDataShellPage extends StatefulWidget {
  final Widget child;

  const MainDataShellPage({
    super.key,
    required this.child,
  });

  @override
  State<MainDataShellPage> createState() => _MainDataShellPageState();
}

class _MainDataShellPageState extends State<MainDataShellPage> {
  bool _showDataMenu = true;

  // Fungsi untuk mengecek apakah router saat ini termasuk dalam modul data utama
  bool _isDataRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return location.startsWith(RouteNames.data); 
  }

  @override
  Widget build(BuildContext context) {
    final isDataRoute = _isDataRoute(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Stack(
        children: [
          // ================= CONTENT =================
          Padding(
            padding: EdgeInsets.only(
              bottom: isDataRoute && _showDataMenu ? 140 : 0,
            ),
            child: widget.child,
          ),

          // ================= DATA POPUP MENU =================
          // Menggunakan Positioned agar melayang di atas konten (Floating)
          if (isDataRoute && _showDataMenu)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24, // Jarak dari bawah layar
              child: MainDataSubBottomNav(
                onClose: () {
                  setState(() {
                    _showDataMenu = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}