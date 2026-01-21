import 'dart:async';
import 'package:flutter/material.dart';

// Import Model & Repo Baru
import '../../data/model/dashboard_header_model.dart';
import '../../data/repo/dashboard_header_repository.dart';

class DashboardHeader extends StatefulWidget {
  final String userName;
  final String userRole;
  final DashboardHeaderModel? data; 

  const DashboardHeader({
    super.key,
    required this.userName,
    this.userRole = 'Polda Jatim',
    this.data, 
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  // Inisialisasi Repository
  final DashboardHeaderRepository _repo = DashboardHeaderRepository();
  
  // Data State (Model Baru)
  late DashboardHeaderModel _headerData;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _setupTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setupTimer() {
    // Update setiap 30 detik agar jam/salam tetap akurat
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _refreshData();
    });
  }

  void _refreshData() {
    setState(() {
      _headerData = _repo.getHeaderData(
        userName: widget.userName,
        userRole: widget.userRole,
      );
    });
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
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(isTablet),
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
                    _headerData.greetingText, // Data dari Model
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _headerData.userName, // Data dari Model
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(alignment: WrapAlignment.center, children: [_buildRoleBadge()]),
        const SizedBox(height: 14),
        Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }

  // --- LAYOUT DESKTOP/TABLET ---
  Widget _buildDesktopLayout(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
                        Text(
                          "${_headerData.greetingText},", // Data dari Model
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _headerData.userName, // Data dari Model
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRoleBadge(),
                        if (widget.data != null) ...[const SizedBox(width: 8)],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (!isTablet) ...[
          Container(
            height: 50,
            width: 1,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 24),
          ),
        ],

        // KANAN: Waktu
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Icon(
        _headerData.greetingIcon, // Icon dari Model
        color: const Color(0xFF2563EB),
        size: iconSize,
      ),
    );
  }

  Widget _buildRoleBadge() {
    return _baseBadge(
      text: _headerData.userRole.toUpperCase(), // Role dari Model
      textColor: const Color(0xFF15803D), // Green
      bgColor: const Color(0xFFF0FDF4),
      borderColor: const Color(0xFFBBF7D0),
      icon: Icons.shield_outlined,
    );
  }

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
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateWidget({required bool isSmall}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isSmall)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: Colors.grey[400],
            ),
          ),
        Text(
          _headerData.formattedDate, // Tanggal dari Model
          style: TextStyle(
            fontSize: isSmall ? 13 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}