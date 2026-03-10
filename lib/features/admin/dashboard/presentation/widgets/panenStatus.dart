import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';

// ==========================================
// DESIGN SYSTEM - Earth & Organic Palette
// ==========================================

class _AppColors {
  // Primary
  static const Color forestGreen = Color(0xFF2D4F1E);
  static const Color forestDark = Color(0xFF1E3A0F);
  static const Color forestLight = Color(0xFF4A7C36);
  
  // Secondary
  static const Color warmBeige = Color(0xFFF5E6CC);
  static const Color terracotta = Color(0xFFE27D60);
  static const Color goldenWheat = Color(0xFFD4A574);
  
  // Neutral
  static const Color slateGrey = Color(0xFF4A4A4A);
  static const Color warmGrey = Color(0xFF8B8680);
  static const Color bgWarm = Color(0xFFFDF8F3);
  static const Color borderWarm = Color(0xFFE8DDD0);
  static const Color textPrimary = Color(0xFF2C3E2D);
  static const Color textSecondary = Color(0xFF5C6B5D);
  
  // Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFEF6C00);
  static const Color info = Color(0xFF1565C0);
}

class _AppTypography {
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: _AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle cardValue = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: _AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle cardLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: _AppColors.textSecondary,
    letterSpacing: 0.5,
    height: 1.3,
  );
  
  static const TextStyle unit = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: _AppColors.warmGrey,
    letterSpacing: 1,
  );
  
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: _AppColors.textPrimary,
    letterSpacing: -0.3,
  );
}

// ==========================================
// MAIN SECTION
// ==========================================

class PanenStatusSection extends StatelessWidget {
  const PanenStatusSection({super.key});

  IconData _getIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains("normal")) return Icons.agriculture_rounded;
    if (l.contains("gagal")) return Icons.warning_rounded;
    if (l.contains("dini")) return Icons.eco_rounded;
    if (l.contains("tebasan")) return Icons.timer_rounded;
    return Icons.bar_chart_rounded;
  }

  Color _getColor(String label) {
    final l = label.toLowerCase();
    if (l.contains("normal")) return _AppColors.success;
    if (l.contains("gagal")) return _AppColors.error;
    if (l.contains("dini")) return _AppColors.warning;
    if (l.contains("tebasan")) return _AppColors.info;
    return _AppColors.forestGreen;
  }

  // ==========================================
  // 2 kolom untuk semua breakpoint
  // ==========================================
  int _responsiveColumn(double width) {
    return 2; // Tetap 2 kolom untuk semua ukuran
  }

  // ==========================================
  // PERBAIKAN: Aspect ratio lebih kecil = card lebih tinggi
  // ==========================================
  double _aspectRatio(double width) {
    if (width > 1400) return 1.4;    // Desktop
    if (width > 1000) return 1.2;    // Tablet large
    if (width > 600) return 1.0;     // Tablet small
    return 0.85;                      // Mobile: lebih tinggi untuk hindari overflow
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final items = provider.dashboardData?.panenStatus ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        _buildHeader(context, items),
        
        const SizedBox(height: 16),
        
        // Content
        if (provider.isLoading)
          const _PanenSkeleton()
        else if (items.isEmpty)
          _buildEmptyState(context)
        else
          _buildGrid(context, items),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, List<dynamic> items) {
    final total = items.fold<double>(0, (sum, item) => sum + (item.value ?? 0));
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_AppColors.forestGreen, _AppColors.forestDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _AppColors.forestGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TOTAL LAHAN PANEN",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${total.toStringAsFixed(2)} HA",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          if (items.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${items.length} Status",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _AppColors.bgWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.borderWarm),
      ),
      child: Column(
        children: [
          Icon(
            Icons.grass_outlined,
            size: 48,
            color: _AppColors.warmGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            "Belum ada data panen",
            style: _AppTypography.sectionTitle.copyWith(
              color: _AppColors.warmGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Data status panen akan muncul di sini",
            style: _AppTypography.cardLabel.copyWith(
              color: _AppColors.warmGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<dynamic> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _responsiveColumn(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: _aspectRatio(constraints.maxWidth),
          ),
          itemBuilder: (_, index) {
            final item = items[index];
            final color = _getColor(item.label);
            
            return _PanenStatusCard(
              icon: _getIcon(item.label),
              value: item.value ?? 0,
              label: item.label,
              color: color,
              index: index,
            );
          },
        );
      },
    );
  }
}

// ==========================================
// ENHANCED CARD - OPTIMIZED ANTI OVERFLOW
// ==========================================

class _PanenStatusCard extends StatefulWidget {
  final IconData icon;
  final double value;
  final String label;
  final Color color;
  final int index;

  const _PanenStatusCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.index,
  });

  @override
  State<_PanenStatusCard> createState() => _PanenStatusCardState();
}

class _PanenStatusCardState extends State<_PanenStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          // Handle tap action
        },
        child: Container(
          // ==========================================
          // PERBAIKAN: Padding lebih kecil untuk hemat space
          // ==========================================
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isPressed 
                  ? widget.color.withOpacity(0.5) 
                  : _AppColors.borderWarm,
              width: _isPressed ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_isPressed ? 0.15 : 0.08),
                blurRadius: _isPressed ? 12 : 8,
                offset: const Offset(0, 3),
                spreadRadius: _isPressed ? 1 : 0,
              ),
            ],
          ),
          child: Column(
            // ==========================================
            // PERBAIKAN: MainAxisSize.min agar Column tidak memaksa tinggi
            // ==========================================
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon & Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color.withOpacity(0.15),
                          widget.color.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: widget.color,
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ==========================================
              // PERBAIKAN: Spacer fleksibel
              // ==========================================
              const SizedBox(height: 8),

              // Middle: Value & Unit
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnimatedNumber(
                    value: widget.value,
                    color: widget.color,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _AppColors.bgWarm,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "HA",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: _AppColors.warmGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              // ==========================================
              // PERBAIKAN: Spacer fleksibel
              // ==========================================
              const SizedBox(height: 8),

              // Bottom: Label
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.color.withOpacity(0.15),
                  ),
                ),
                child: Text(
                  widget.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// ENHANCED ANIMATED NUMBER
// ==========================================

class _AnimatedNumber extends StatefulWidget {
  final double value;
  final Color color;

  const _AnimatedNumber({
    required this.value,
    required this.color,
  });

  @override
  State<_AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<_AnimatedNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = widget.value * _animation.value;
        return Text(
          currentValue.toStringAsFixed(1), // 1 desimal saja
          style: TextStyle(
            fontSize: 22, // Lebih kecil
            fontWeight: FontWeight.w800,
            color: widget.color,
            letterSpacing: -0.5,
          ),
        );
      },
    );
  }
}

// ==========================================
// ENHANCED SKELETON - 2 COLUMNS
// ==========================================

class _PanenSkeleton extends StatelessWidget {
  const _PanenSkeleton();

  int _responsiveColumn(double width) {
    return 2;
  }

  double _aspectRatio(double width) {
    if (width > 1400) return 1.4;
    if (width > 1000) return 1.2;
    if (width > 600) return 1.0;
    return 0.85;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _responsiveColumn(constraints.maxWidth);
        final ratio = _aspectRatio(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: ratio,
          ),
          itemBuilder: (_, index) {
            return _SkeletonCard(index: index);
          },
        );
      },
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  final int index;
  const _SkeletonCard({required this.index});

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _AppColors.bgWarm,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _AppColors.borderWarm),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(_animation.value),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 70,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(_animation.value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(_animation.value),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}