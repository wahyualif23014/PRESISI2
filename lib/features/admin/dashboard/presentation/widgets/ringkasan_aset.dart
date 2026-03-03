import 'package:flutter/material.dart';
import '../../data/model/ringkasan_area_model.dart'; 

enum CardLayoutType { list, grid }

class LahanStatCard extends StatelessWidget {
  final RingkasanAreaModel data; 
  final CardLayoutType layoutType;

  const LahanStatCard({
    super.key,
    required this.data,
    this.layoutType = CardLayoutType.grid,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = data.backgroundColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          // Pemilihan tata letak berdasarkan layoutType
          layoutType == CardLayoutType.list
              ? _buildVerticalListLayout()
              : _buildGridLayout(),
          const SizedBox(height: 12),
          // Judul Footer (Centered)
          Center(
            child: Text(
              data.title.toUpperCase(), 
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
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
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "Total Keseluruhan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _formatNumber(data.totalValue),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            const Text(
              "HA",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
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
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "${item.label} :",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "${_formatNumber(item.value)} HA",
                style: const TextStyle(
                  color: Color(0xFF1E88E5), // Biru informatif
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridLayout() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: data.items.map((item) {
        return LayoutBuilder(builder: (context, constraints) {
          // Menghitung lebar agar muat 2 kolom dalam grid card
          return Container(
            width: (100), 
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CategoryIcon(groupTitle: data.title, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    "${_formatNumber(item.value)} HA",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        });
      }).toList(),
    );
  }

  String _formatNumber(double number) {
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(2);
  }
}

class _CategoryIcon extends StatelessWidget {
  final String groupTitle;
  final double size;

  const _CategoryIcon({required this.groupTitle, this.size = 20});

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.grid_view_rounded;
    final title = groupTitle.toUpperCase();

    if (title.contains("PRODUKTIF")) iconData = Icons.settings_suggest_rounded;
    if (title.contains("HUTAN")) iconData = Icons.park_rounded;
    if (title.contains("LBS")) iconData = Icons.agriculture_rounded;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFFFA726), // Orange accent per desain
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: size * 0.7, color: Colors.white),
    );
  }
}