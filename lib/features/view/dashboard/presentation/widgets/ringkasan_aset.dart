import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/ringkasan_area_model.dart'; 

enum CardLayoutType { list, grid }

class LahanStatCard extends StatelessWidget {
  final RingkasanAreaModel data; 
  final Color backgroundColor;
  final CardLayoutType layoutType;

  const LahanStatCard({
    super.key,
    required this.data,
    required this.backgroundColor,
    this.layoutType = CardLayoutType.grid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          layoutType == CardLayoutType.list
              ? _buildVerticalListLayout()
              : _buildGridLayout(context),
          const SizedBox(height: 16),
          Text(
            data.title, 
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Data",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Total Keseluruhan",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatNumber(data.totalValue),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 5),
              child: Text(
                "HA",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalListLayout() {
    return Column(
      children: data.items.map((item) {
        return _StatListItem(
          label: item.label,
          value: item.value,
          category: item.category,
        );
      }).toList(),
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: data.items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: _StatGridItem(
                value: item.value,
                category: item.category,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatNumber(double number) {
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(2);
  }
}

class _StatListItem extends StatelessWidget {
  final String label;
  final double value;
  final LandCategory category;

  const _StatListItem({
    required this.label,
    required this.value,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          _CategoryIcon(category: category),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatNumber(value),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                "HA",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(2);
  }
}

class _StatGridItem extends StatelessWidget {
  final double value;
  final LandCategory category;

  const _StatGridItem({
    required this.value,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _CategoryIcon(category: category, size: 24),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "${_formatNumber(value)} HA",
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(2);
  }
}

class _CategoryIcon extends StatelessWidget {
  final LandCategory category;
  final double size;

  const _CategoryIcon({
    required this.category,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;

    switch (category) {
      case LandCategory.productive:
        iconData = Icons.settings_suggest_rounded;
        break;
      case LandCategory.forestry:
        iconData = Icons.park_rounded;
        break;
      case LandCategory.agriculture:
        iconData = Icons.agriculture_rounded;
        break;
      case LandCategory.religious:
        iconData = Icons.mosque_rounded;
        break;
      default:
        iconData = Icons.circle;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFFA726),
          width: 2,
        ),
      ),
      child: Icon(
        iconData,
        size: size * 0.6,
        color: Colors.black87,
      ),
    );
  }
}