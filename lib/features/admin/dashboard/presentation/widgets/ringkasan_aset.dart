import 'package:flutter/material.dart';
import '../../data/model/ringkasan_area_model.dart';

enum CardLayoutType { list, compact }

class LahanStatCard extends StatefulWidget {
  final RingkasanAreaModel data;
  final CardLayoutType layoutType;
  final VoidCallback? onTap;
  final bool isElevated;
  final bool initiallyExpanded;
  final int previewItemCount;

  const LahanStatCard({
    super.key,
    required this.data,
    this.layoutType = CardLayoutType.list,
    this.onTap,
    this.isElevated = false,
    this.initiallyExpanded = false,
    this.previewItemCount = 3,
  });

  @override
  State<LahanStatCard> createState() => _LahanStatCardState();
}

class _LahanStatCardState extends State<LahanStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = widget.data.backgroundColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 20),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor,
                Color.lerp(cardColor, Colors.black, 0.15) ?? cardColor,
              ],
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(isDark ? 0.4 : 0.3),
                blurRadius: widget.isElevated ? 30 : 20,
                offset: Offset(0, widget.isElevated ? 15 : 10),
                spreadRadius: -5,
              ),
              if (widget.isElevated)
                BoxShadow(
                  color: cardColor.withOpacity(0.2),
                  blurRadius: 60,
                  offset: const Offset(0, 20),
                  spreadRadius: -10,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
            child: Stack(
              children: [
                // Background Pattern
                Positioned(
                  right: -30,
                  top: -30,
                  child: Opacity(
                    opacity: 0.08,
                    child: Icon(
                      _getBackgroundIcon(),
                      size: isSmallScreen ? 100 : 140,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(isSmallScreen),
                      const SizedBox(height: 16),
                      _buildContent(isSmallScreen),
                      const SizedBox(height: 12),
                      _buildFooter(isSmallScreen),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "DATA STATISTIK",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isSmallScreen ? 9 : 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.data.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  height: 1.2,
                ),
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildTotalValue(isSmallScreen),
      ],
    );
  }

  Widget _buildTotalValue(bool isSmallScreen) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widget.data.totalValue),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 10 : 12, 
            vertical: isSmallScreen ? 6 : 8
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(value),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "HEKTAR",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isSmallScreen ? 8 : 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isSmallScreen) {
    final items = widget.data.items;
    final displayItems = _isExpanded 
        ? items 
        : items.take(widget.previewItemCount).toList();
    final hasMoreItems = items.length > widget.previewItemCount;

    return Column(
      children: [
        // Vertical List Layout (Mobile Optimized)
        _buildVerticalList(displayItems, isSmallScreen),
        
        // Expand/Collapse Button
        if (hasMoreItems) ...[
          const SizedBox(height: 12),
          _buildExpandButton(isSmallScreen, items.length),
        ],
      ],
    );
  }

  Widget _buildVerticalList(List<dynamic> items, bool isSmallScreen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: Column(
        children: List.generate(items.length, (index) {
          final delay = (index * 0.08).clamp(0.0, 0.4);
          return _buildStaggeredItem(
            index: index,
            delay: delay,
            child: _VerticalItemRow(
              item: items[index],
              groupTitle: widget.data.title,
              isLast: index == items.length - 1,
              isSmallScreen: isSmallScreen,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildExpandButton(bool isSmallScreen, int totalItems) {
    return GestureDetector(
      onTap: _toggleExpand,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 14 : 16, 
          vertical: isSmallScreen ? 8 : 10
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withOpacity(0.9),
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _isExpanded 
                ? "Sembunyikan" 
                : "Lihat ${totalItems - widget.previewItemCount} data lainnya",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isSmallScreen ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredItem({
    required int index,
    required double delay,
    required Widget child,
  }) {
    final itemAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay,
        (delay + 0.6).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: itemAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - itemAnimation.value) * 15),
          child: Opacity(
            opacity: itemAnimation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildFooter(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: isSmallScreen ? 11 : 12,
                color: Colors.white.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                "Updated today",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: isSmallScreen ? 9 : 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (widget.onTap != null)
            Row(
              children: [
                Text(
                  "Details",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isSmallScreen ? 9 : 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: isSmallScreen ? 9 : 10,
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
        ],
      ),
    );
  }

  IconData _getBackgroundIcon() {
    final title = widget.data.title.toUpperCase();
    if (title.contains("PRODUKTIF")) return Icons.agriculture_rounded;
    if (title.contains("HUTAN")) return Icons.forest_rounded;
    if (title.contains("LAHAN")) return Icons.terrain_rounded;
    if (title.contains("TANAM")) return Icons.spa_rounded;
    if (title.contains("PANEN")) return Icons.inventory_rounded;
    return Icons.landscape_rounded;
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1)}M";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}K";
    }
    return number % 1 == 0
        ? number.toInt().toString()
        : number.toStringAsFixed(1);
  }
}

// ==================== VERTICAL ITEM ROW ====================

class _VerticalItemRow extends StatelessWidget {
  final dynamic item;
  final String groupTitle;
  final bool isLast;
  final bool isSmallScreen;

  const _VerticalItemRow({
    required this.item,
    required this.groupTitle,
    this.isLast = false,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _getProgressValue(),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                    minHeight: isSmallScreen ? 4 : 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(item.value),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 13 : 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "ha",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isSmallScreen ? 8 : 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getProgressValue() {
    // Calculate progress based on item value vs max value in group
    // This is a placeholder - you might want to pass max value from parent
    return 0.7; // Default 70% for visual
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getIconData(),
        size: isSmallScreen ? 14 : 16,
        color: Colors.white,
      ),
    );
  }

  IconData _getIconData() {
    final title = groupTitle.toUpperCase();
    if (title.contains("PRODUKTIF")) return Icons.settings_suggest_rounded;
    if (title.contains("HUTAN")) return Icons.park_rounded;
    if (title.contains("TANAM")) return Icons.spa_rounded;
    if (title.contains("PANEN")) return Icons.inventory_2_rounded;
    return Icons.grid_view_rounded;
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}k";
    }
    return number % 1 == 0
        ? number.toInt().toString()
        : number.toStringAsFixed(1);
  }
}