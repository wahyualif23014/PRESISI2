import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdmapp/auth/provider/auth_provider.dart';
import 'package:sdmapp/presentation/profile/profile_page.dart';

class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final String userName = auth.user?.nama ?? "Tamu";
    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : "U";

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        tooltip: "Profil Saya",
        
        // Avatar UI
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFF97316), // Orange Professional
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Action Handler
        onSelected: (value) {
          if (value == 'logout') {
            context.read<AuthProvider>().logout();
          } else if (value == 'profile') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },

        // Menu Items
        itemBuilder: (context) => [
          // Header (Non-clickable)
          PopupMenuItem<String>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $userName",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  "Administrator",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Divider(height: 24),
              ],
            ),
          ),
          
          // Menu Options
          _buildMenuItem('profile', Icons.person_outline, "Profil Saya", Colors.black87),
          _buildMenuItem('logout', Icons.logout_rounded, "Keluar", Colors.red.shade600),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text, Color color) {
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}