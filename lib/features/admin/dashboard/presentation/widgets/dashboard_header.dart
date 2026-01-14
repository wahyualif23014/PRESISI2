import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'dart:async';

// Import Model untuk mengambil data dummy (jumlahPersonel)
import '../../data/model/dasboard_model.dart'; 

class DashboardHeader extends StatefulWidget {
  final String userName;
  final String userRole;
  final DashboardModel? data; // Tambahkan ini untuk menerima data dummy

  const DashboardHeader({
    super.key,
    required this.userName,
    this.userRole = 'Polda Jatim',
    this.data, // Optional, karena saat loading data mungkin null
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  late String _currentTime;
  late String _currentDate;
  late String _greeting;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _setupTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setupTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) setState(() => _updateDateTime());
    });
  }

  void _updateDateTime() {
    final now = DateTime.now();
    _currentTime = DateFormat('HH:mm').format(now);
    // Pastikan locale id_ID sudah diinitialize di main.dart atau gunakan string biasa
    try {
      _currentDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
    } catch (e) {
      // Fallback jika locale belum siap
      _currentDate = DateFormat('EEEE, d MMMM yyyy').format(now);
    }
    
    final hour = now.hour;
    if (hour < 11) _greeting = 'Selamat Pagi';
    else if (hour < 15) _greeting = 'Selamat Siang';
    else if (hour < 18) _greeting = 'Selamat Sore';
    else _greeting = 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    // Responsive Logic
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    final isTablet = width >= 768 && width < 1200;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Sedikit lebih bulat
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isMobile 
        ? _buildMobileLayout() 
        : _buildDesktopLayout(isTablet),
    );
  }

  // --- LAYOUT MOBILE ---
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildGreetingIcon(size: 48, iconSize: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                  Text(
                    widget.userName,
                    style: const TextStyle(fontSize: 18, color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Baris Badge: Role & Personel (Data Dummy)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildRoleBadge(),
            if (widget.data != null) _buildPersonelBadge(), // Tampilkan jika data ada
          ],
        ),
        const SizedBox(height: 20),
        Divider(height: 1, color: Colors.grey.shade100),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDateWidget(isSmall: true),
            _buildTimeWidget(isSmall: true),
          ],
        ),
      ],
    );
  }

  // --- LAYOUT DESKTOP/TABLET ---
  Widget _buildDesktopLayout(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // KIRI: Icon, Nama, Role, Personel
        Expanded(
          child: Row(
            children: [
              _buildGreetingIcon(size: 56, iconSize: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text("$_greeting,", style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            widget.userName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRoleBadge(),
                        if (widget.data != null) ...[
                          const SizedBox(width: 8),
                          _buildPersonelBadge(), // Mengambil dari Dummy
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (!isTablet) ...[
          Container(height: 50, width: 1, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 24)),
        ],

        // KANAN: Waktu
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeWidget(isSmall: false),
            const SizedBox(height: 4),
            _buildDateWidget(isSmall: false),
          ],
        ),
      ],
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildGreetingIcon({required double size, required double iconSize}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Icon(_getGreetingIcon(), color: const Color(0xFF2563EB), size: iconSize),
    );
  }

  Widget _buildRoleBadge() {
    return _baseBadge(
      text: widget.userRole.toUpperCase(),
      textColor: const Color(0xFF15803D), // Green
      bgColor: const Color(0xFFF0FDF4),
      borderColor: const Color(0xFFBBF7D0),
      icon: Icons.shield_outlined,
    );
  }

  // Widget baru untuk menampilkan Data Personel dari Dummy
  Widget _buildPersonelBadge() {
    return _baseBadge(
      text: "${widget.data!.jumlahPersonel} PERSONEL", // Ambil dari Model
      textColor: const Color(0xFF0369A1), // Sky Blue
      bgColor: const Color(0xFFF0F9FF),
      borderColor: const Color(0xFFBAE6FD),
      icon: Icons.people_outline,
    );
  }

  // Template Badge agar konsisten
  Widget _baseBadge({
    required String text, 
    required Color textColor, 
    required Color bgColor, 
    required Color borderColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDateWidget({required bool isSmall}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isSmall) Padding(padding: const EdgeInsets.only(right: 6), child: Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[400])),
        Text(_currentDate, style: TextStyle(fontSize: isSmall ? 13 : 14, fontWeight: FontWeight.w500, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildTimeWidget({required bool isSmall}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_currentTime, style: TextStyle(fontSize: isSmall ? 20 : 28, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B), height: 1)),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
          child: Text('WIB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        ),
      ],
    );
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return Icons.wb_sunny_rounded;
    if (hour >= 11 && hour < 15) return Icons.wb_sunny_outlined;
    if (hour >= 15 && hour < 18) return Icons.wb_twilight_rounded;
    return Icons.nightlight_round_rounded;
  }
}