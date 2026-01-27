import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sdmapp/presentation/notif/notification_page.dart';
import 'profile_menu_button.dart'; // Import widget profil terpisah

class AdminTopBar extends StatelessWidget {
  final double height;
  const AdminTopBar({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final String title = _getPageTitle(location);

    return Container(
      height: height + MediaQuery.of(context).padding.top, // Handle Notch/Status Bar
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF19252B),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Shadow lebih halus & modern
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Notification Icon (Left)
          _buildNotificationButton(context),

          // 2. Title & Subtitle (Center)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white, // Slate 800
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "Sistem Ketahanan Pangan",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // 3. Profile Dropdown (Right)
          const ProfileMenuButton(),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationPage()),
        ),
        icon: const Icon(Icons.notifications_outlined, size: 22),
        color: Colors.black54,
        splashRadius: 20,
        tooltip: "Notifikasi",
      ),
    );
  }

  // Logic Mapping Judul (Clean & Maintainable)
  String _getPageTitle(String location) {
    if (location.contains('dashboard')) return "DASHBOARD";
    if (location.contains('units')) return "DATA KESATUAN";
    if (location.contains('land')) return "KELOLA LAHAN";
    if (location.contains('recap')) return "REKAPITULASI";
    if (location.contains('personnel')) return "DATA PERSONEL";
    if (location.contains('positions')) return "DATA JABATAN";
    if (location.contains('regions')) return "DATA WILAYAH";
    if (location.contains('commodities')) return "DATA KOMODITAS";
    return "PRESISI SYSTEM";
  }
}