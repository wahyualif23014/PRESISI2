import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Pastikan import go_router
import '../../auth/provider/auth_provider.dart'; // Sesuaikan path import ini
import '../../router/route_names.dart'; // Sesuaikan path route names

class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil Data dari Provider
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final String userName = user?.namaLengkap ?? "Tamu";
    
    // --- PERBAIKAN 1: Handle idJabatan (int) ke String ---
    // Jangan gunakan 'as String', tapi gunakan .toString()
    // Anda bisa mempercantik ini nanti dengan logic if(id==1) return "Admin" dst.
    final String userJabatan = user?.idJabatan != null 
        ? "Jabatan: ${user!.idJabatan}" 
        : "Pengguna";

    // --- PERBAIKAN 2: Gunakan idTugas untuk menggantikan NRP ---
    final String userId = user?.idTugas ?? "-"; 
    
    // Ambil inisial huruf pertama
    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : "U";

    // Warna Tema (Konsisten)
    const Color primaryGold = Color(0xFFC0A100);

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          color: Colors.white,
          surfaceTintColor: Colors.white, // Mencegah tint ungu di Material 3
        ),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        tooltip: "Profil Saya",
        
        // --- 2. Avatar UI ---
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryGold.withOpacity(0.5), width: 1.5),
          ),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: primaryGold,
            backgroundImage: (user?.fotoProfil != null && user!.fotoProfil!.isNotEmpty)
                ? NetworkImage(user.fotoProfil!)
                : null,
            child: (user?.fotoProfil == null || user!.fotoProfil!.isEmpty)
                ? Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),

        // --- 3. Action Handler ---
        onSelected: (value) {
          if (value == 'logout') {
            context.read<AuthProvider>().logout();
            context.go(RouteNames.login); // Gunakan go_router untuk navigasi aman
          } else if (value == 'profile') {
            // Gunakan pushNamed dari go_router atau Navigator biasa
             context.pushNamed(RouteNames.profile);
            // Atau jika pakai Navigator biasa:
            // Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
          }
        },

        // --- 4. Menu Items ---
        itemBuilder: (context) => [
          // HEADER: Nama, Jabatan, ID (Non-clickable)
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
                const SizedBox(height: 4),
                // Menampilkan Jabatan & ID Tugas
                Text(
                  "$userJabatan ($userId)", 
                  style: TextStyle(
                    fontSize: 11, 
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  // Helper Widget untuk Item Menu
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