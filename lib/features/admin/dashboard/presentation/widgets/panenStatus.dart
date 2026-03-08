import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';

class PanenStatusSection extends StatelessWidget {
  const PanenStatusSection({super.key});

  IconData _getIcon(String label) {
    final l = label.toLowerCase();

    if (l.contains("normal")) return Icons.agriculture;
    if (l.contains("gagal")) return Icons.warning_amber_rounded;
    if (l.contains("dini")) return Icons.eco;
    if (l.contains("tebasan")) return Icons.hourglass_bottom;

    return Icons.bar_chart;
  }

  Color _getColor(String label) {
    final l = label.toLowerCase();

    if (l.contains("normal")) return const Color(0xFF2E7D32);
    if (l.contains("gagal")) return const Color(0xFFC62828);
    if (l.contains("dini")) return const Color(0xFFEF6C00);
    if (l.contains("tebasan")) return const Color(0xFF1565C0);

    return Colors.blueGrey;
  }

  int _responsiveColumn(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2;
  }

  double _aspectRatio(double width) {
    if (width > 1200) return 1.4;
    if (width > 800) return 1.25;
    return 1.1;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final items = provider.dashboardData?.panenStatus ?? [];

    if (provider.isLoading) {
      return const _PanenSkeleton();
    }

    if (items.isEmpty) {
      return const SizedBox();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _responsiveColumn(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

            return _PanenStatusCard(
              icon: _getIcon(item.label),
              value: item.value,
              label: item.label,
              color: _getColor(item.label),
            );
          },
        );
      },
    );
  }
}

class _PanenStatusCard extends StatelessWidget {
  final IconData icon;
  final double value;
  final String label;
  final Color color;

  const _PanenStatusCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(.12),
            color.withOpacity(.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// ICON
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),

          /// VALUE
          FittedBox(
            child: _AnimatedNumber(value: value),
          ),

          /// UNIT
          const Text(
            "HA",
            style: TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),

          /// LABEL
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedNumber extends StatelessWidget {
  final double value;

  const _AnimatedNumber({required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 700),
      builder: (_, val, __) {
        return Text(
          val.toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

class _PanenSkeleton extends StatelessWidget {
  const _PanenSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
          ),
        );
      },
    );
  }
}