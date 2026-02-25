import 'package:flutter/material.dart';

// Import Model (Pastikan path benar)
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/dashboard_header_model.dart';

class DashboardHeader extends StatefulWidget {
  final String userName;
  final String userRole;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.userRole = 'Polda Jatim',
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  DashboardHeaderModel? _headerData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    // Simulasi Logic Greeting yang Friendly
    final hour = DateTime.now().hour;
    String greeting = "Semangat Pagi";
    
    if (hour >= 11 && hour < 15) {
      greeting = "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      greeting = "Selamat Sore";
    } else if (hour >= 18) {
      greeting = "Selamat Beristirahat";
    }

    setState(() {
      _headerData = DashboardHeaderModel(
        userName: widget.userName,
        userRole: widget.userRole,
        greetingText: greeting,
        greetingIcon: Icons.emoji_people_rounded, // Icon placeholder
        formattedDate: '', // Tidak dipakai
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_headerData == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      // Padding dibuat lebih tipis (vertical 16)
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        // Gradient Gelap (Kontras dengan BG Putih)
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B), // Slate 800
            Color(0xFF334155), // Slate 700
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16), // Radius sudut lebih kecil (clean)
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // KIRI: Greeting & Nama User
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Agar tinggi fit content
              children: [
                Row(
                  children: [
                    Text(
                      _headerData!.greetingText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8), // Slate 400 (Abu muda)
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.waving_hand_rounded, // Icon tangan melambai
                      size: 14,
                      color: Color(0xFFF59E0B), // Amber (Emas)
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white, // Teks putih di atas gelap
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // KANAN: Badge Role (Polda Jatim)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // Transparan putih
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_outlined, 
                  size: 14, 
                  color: Color(0xFF4ADE80), // Hijau Neon
                ),
                const SizedBox(width: 6),
                Text(
                  widget.userRole.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}