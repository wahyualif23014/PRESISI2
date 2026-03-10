import 'package:flutter/material.dart';
import '../../data/model/dashboard_header_model.dart';

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
        greetingIcon: Icons.emoji_people_rounded,
        formattedDate: '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_headerData == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF334155),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF020617).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _headerData!.greetingText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFCBD5F5),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.waving_hand_rounded,
                      size: 16,
                      color: Color(0xFFFBBF24),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF4ADE80).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 15,
                    color: Color(0xFF4ADE80),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.userRole.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE2E8F0),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}