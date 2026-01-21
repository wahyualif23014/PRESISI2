import 'package:flutter/material.dart';

class DashboardHeaderModel {
  final String userName;
  final String userRole;
  final String formattedDate; // Contoh: "Senin, 21 Januari 2026"
  final String greetingText;  // Contoh: "Selamat Pagi🙌"
  final IconData greetingIcon; // Contoh: Icons.wb_sunny_rounded

  const DashboardHeaderModel({
    required this.userName,
    required this.userRole,
    required this.formattedDate,
    required this.greetingText,
    required this.greetingIcon,
  });
}