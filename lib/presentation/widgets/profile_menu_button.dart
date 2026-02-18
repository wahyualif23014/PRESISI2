import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; 

import '../../auth/provider/auth_provider.dart';
import '../../router/route_names.dart';

class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final String userName = user?.namaLengkap ?? "Tamu";
    
    // --- PERBAIKAN LOGIC JABATAN ---
    // Pastikan tidak membandingkan JabatanModel (objek) dengan 0 (int)
    final String displayJabatan = user?.jabatanDetail?.namaJabatan ?? 
        (user?.idJabatan != 0 ? "ID: ${user?.idJabatan}" : "Anggota");

    // Menampilkan Nama Satuan/Unit Tugas
    final String unitLocation = user?.tingkatDetail?.nama ?? "-";
    final String userNrp = user?.nrp ?? "-"; 
    
    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : "U";
    const Color primaryGold = Color(0xFFC0A100);

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8, color: Colors.white, surfaceTintColor: Colors.white, 
        ),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        tooltip: "Profil Saya",
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryGold.withOpacity(0.5), width: 1.5)),
          child: CircleAvatar(
            radius: 16, backgroundColor: primaryGold,
            backgroundImage: (user?.fotoProfil != null && user!.fotoProfil!.isNotEmpty) ? NetworkImage(user.fotoProfil!) : null,
            child: (user?.fotoProfil == null || user!.fotoProfil!.isEmpty) ? Text(initial, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)) : null,
          ),
        ),
        onSelected: (value) async {
          if (value == 'logout') {
            await context.read<AuthProvider>().logout();
            if (context.mounted) context.go(RouteNames.login); 
          } else if (value == 'profile') {
             context.pushNamed(RouteNames.profile);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                // Menampilkan Jabatan & Nama Satuan (Unit)
                Text(displayJabatan, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                Text(unitLocation.toUpperCase(), style: const TextStyle(fontSize: 10, color: primaryGold, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text("NRP: $userNrp | ${user?.roleDisplay}", style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                const Divider(height: 24),
              ],
            ),
          ),
          _buildMenuItem('profile', Icons.person_outline, "Profil Saya", Colors.black87),
          _buildMenuItem('logout', Icons.logout_rounded, "Keluar", Colors.red.shade600),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text, Color color) {
    return PopupMenuItem<String>(
      value: value, height: 44,
      child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 12), Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600))]),
    );
  }
}