import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/dashboard_header_model.dart';

class DashboardHeaderRepository {
  
  // Method utama untuk generate data header saat ini
  DashboardHeaderModel getHeaderData({
    required String userName, 
    required String userRole
  }) {
    final now = DateTime.now();
    
    return DashboardHeaderModel(
      userName: userName,
      userRole: userRole,
      formattedDate: _getFormattedDate(now),
      greetingText: _getGreetingText(now.hour),
      greetingIcon: _getGreetingIcon(now.hour),
    );
  }

  // --- LOGIC HELPERS (Dipindahkan dari Widget lama) ---

  String _getFormattedDate(DateTime date) {
    try {
      // Coba format Indonesia (pastikan initializeDateFormatting sudah dipanggil di main jika error)
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      // Fallback default jika locale id_ID belum siap
      return DateFormat('EEEE, d MMMM yyyy').format(date);
    }
  }

  String _getGreetingText(int hour) {
    if (hour < 11) return 'Selamat Pagi🙌';
    if (hour < 15) return 'Selamat Siang🙌';
    if (hour < 18) return 'Selamat Sore🙌';
    return 'Selamat Malam🙌';
  }

  IconData _getGreetingIcon(int hour) {
    if (hour >= 5 && hour < 11) return Icons.wb_sunny_rounded;
    if (hour >= 11 && hour < 15) return Icons.wb_sunny_outlined;
    if (hour >= 15 && hour < 18) return Icons.wb_twilight_rounded;
    return Icons.nightlight_round_rounded;
  }
}