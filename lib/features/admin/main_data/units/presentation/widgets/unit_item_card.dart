import 'package:KETAHANANPANGAN/features/admin/main_data/units/data/models/unit_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnitItemCard extends StatelessWidget {
  final UnitModel unit;
  final bool isExpanded;
  final VoidCallback? onExpandTap;
  final VoidCallback? onPhoneTap;

  const UnitItemCard({
    super.key,
    required this.unit,
    this.isExpanded = false,
    this.onExpandTap,
    this.onPhoneTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Color Palette Profesional
    final colors = _CardColors(isPolres: unit.isPolres);
    
    // ✅ Typography Scale
    final typography = _CardTypography(isPolres: unit.isPolres);

    return Container(
      margin: _getMargin(),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.border,
          width: unit.isPolres ? 1.5 : 1,
        ),
        boxShadow: unit.isPolres ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: unit.isPolres ? onExpandTap : null,
          borderRadius: BorderRadius.circular(12),
          splashColor: colors.splashColor,
          highlightColor: colors.highlightColor,
          child: Padding(
            padding: _getPadding(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Leading Indicator (Polres Only)
                if (unit.isPolres) ...[
                  _buildLeadingIndicator(colors),
                  const SizedBox(width: 12),
                ],

                // ✅ Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title Row dengan Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              unit.title,
                              style: typography.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!unit.isPolres) ...[
                            const SizedBox(width: 8),
                            _buildPolsekBadge(),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Divider tipis untuk Polres
                      if (unit.isPolres) ...[
                        Container(
                          height: 1,
                          color: colors.divider,
                          margin: const EdgeInsets.only(bottom: 8),
                        ),
                      ],

                      // Subtitle (Pejabat)
                      if (_hasValidSubtitle()) ...[
                        _buildSubtitleRow(typography, colors),
                        const SizedBox(height: 10),
                      ],

                      // Phone Number dengan desain modern
                      if (_hasValidPhone()) ...[
                        _buildPhoneChip(colors),
                        const SizedBox(height: 10),
                      ],

                      // Footer info (Wilayah/Kode)
                      _buildFooterChip(colors, typography),
                    ],
                  ),
                ),

                // ✅ Expand Icon (Polres only)
                if (unit.isPolres) ...[
                  const SizedBox(width: 12),
                  _buildExpandIcon(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ LEADING INDICATOR untuk Polres
  Widget _buildLeadingIndicator(_CardColors colors) {
    return Container(
      width: 4,
      height: 48,
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ✅ POLSEK BADGE
  Widget _buildPolsekBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 10,
            color: Colors.amber[700],
          ),
          const SizedBox(width: 4),
          Text(
            'POLSEK',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.amber[800],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ SUBTITLE ROW dengan icon
  Widget _buildSubtitleRow(_CardTypography typography, _CardColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.person_outline_rounded,
          size: 14,
          color: colors.secondaryText,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            unit.subtitle,
            style: typography.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ✅ PHONE CHIP yang modern dan interaktif
  Widget _buildPhoneChip(_CardColors colors) {
    return GestureDetector(
      onTap: onPhoneTap,
      onLongPress: () {}, // Handled by parent
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade50,
              Colors.green.shade100.withOpacity(0.5),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_rounded,
                size: 12,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              unit.phoneNumber!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green[800],
                letterSpacing: 0.3,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'HUBUNGI',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: Colors.green[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FOOTER CHIP (Wilayah/Kode/Polsek count)
  Widget _buildFooterChip(_CardColors colors, _CardTypography typography) {
    final isPolsekCount = unit.count.toLowerCase().contains('polsek');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPolsekCount ? colors.accentLight : colors.mutedBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPolsekCount ? colors.accent.withOpacity(0.3) : colors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPolsekCount ? Icons.account_tree_rounded : Icons.location_on_outlined,
            size: 12,
            color: isPolsekCount ? colors.accent : colors.mutedText,
          ),
          const SizedBox(width: 6),
          Text(
            unit.count,
            style: isPolsekCount 
              ? typography.badgeHighlight
              : typography.badge,
          ),
        ],
      ),
    );
  }

  // ✅ EXPAND ICON dengan animasi
  Widget _buildExpandIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: AnimatedRotation(
        turns: isExpanded ? 0.5 : 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.grey.shade600,
          size: 20,
        ),
      ),
    );
  }

  // ✅ HELPERS
  bool _hasValidSubtitle() {
    return unit.subtitle.isNotEmpty && 
           unit.subtitle != 'Ka: ' && 
           unit.subtitle != 'Ka: / ';
  }

  bool _hasValidPhone() {
    return unit.phoneNumber != null && 
           unit.phoneNumber != '-' && 
           unit.phoneNumber!.isNotEmpty;
  }

  EdgeInsets _getMargin() {
    if (unit.isPolres) {
      return const EdgeInsets.only(bottom: 12);
    }
    return EdgeInsets.zero;
  }

  EdgeInsets _getPadding() {
    if (unit.isPolres) {
      return const EdgeInsets.all(16);
    }
    return const EdgeInsets.symmetric(horizontal: 14, vertical: 12);
  }

  void _copyToClipboard(BuildContext context) {
    if (unit.phoneNumber != null) {
      Clipboard.setData(ClipboardData(text: unit.phoneNumber!));
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[300], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nomor ${unit.phoneNumber} disalin',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey[900],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

// ✅ COLOR PALETTE SYSTEM
class _CardColors {
  final bool isPolres;

  _CardColors({required this.isPolres});

  Color get background => isPolres 
    ? Colors.white 
    : const Color(0xFFF8FAFC);

  Color get border => isPolres 
    ? const Color(0xFFE2E8F0) 
    : const Color(0xFFE2E8F0).withOpacity(0.5);

  Color get accent => const Color(0xFF1E40AF); // Blue 800
  Color get accentLight => const Color(0xFFDBEAFE); // Blue 100

  Color get secondaryText => const Color(0xFF64748B); // Slate 500
  Color get mutedText => const Color(0xFF94A3B8); // Slate 400
  Color get mutedBackground => const Color(0xFFF1F5F9); // Slate 100

  Color get divider => const Color(0xFFE2E8F0).withOpacity(0.8);

  Color get splashColor => isPolres 
    ? const Color(0xFFDBEAFE).withOpacity(0.3) 
    : Colors.grey.shade200.withOpacity(0.3);

  Color get highlightColor => isPolres 
    ? const Color(0xFFDBEAFE).withOpacity(0.1) 
    : Colors.transparent;
}

// ✅ TYPOGRAPHY SYSTEM
class _CardTypography {
  final bool isPolres;

  _CardTypography({required this.isPolres});

  TextStyle get title => TextStyle(
    fontSize: isPolres ? 16 : 14,
    fontWeight: FontWeight.w700,
    color: isPolres ? const Color(0xFF1E3A8A) : const Color(0xFF334155),
    letterSpacing: 0.2,
    height: 1.3,
    fontFamily: 'Inter', // Pastikan font ini tersedia atau hapus
  );

  TextStyle get subtitle => const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF475569),
    letterSpacing: 0.1,
    height: 1.4,
  );

  TextStyle get badge => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Color(0xFF64748B),
    letterSpacing: 0.2,
  );

  TextStyle get badgeHighlight => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1E40AF),
    letterSpacing: 0.2,
  );
}