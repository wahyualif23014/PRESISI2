import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String year;
  final double data;
  final bool isActive; // Status apakah kartu ini sedang dipilih
  final VoidCallback onTap; // Callback saat kartu diklik

  const StatisticsCard({
    super.key,
    required this.title,
    required this.year,
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Warna background & text berubah saat aktif agar lebih menonjol
    final bgColor = isActive ? const Color(0xFF7C6FDE) : Colors.white; // Ungu vs Putih
    final titleColor = isActive ? Colors.white70 : const Color(0xFF64748B);
    final valueColor = isActive ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isActive ? Colors.white60 : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        // Lebar akan diatur oleh Parent (Flex/Expanded), jadi di sini kita atur margin/padding
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isActive 
                  ? const Color(0xFF7C6FDE).withOpacity(0.3) 
                  : const Color(0xFF64748B).withOpacity(0.08),
              blurRadius: isActive ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: isActive ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Judul
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 4, height: 16,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  margin: const EdgeInsets.only(right: 8),
                ),
                Expanded(
                  child: Text(
                    "$title $year",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Angka Utama
            Text(
              _formatNumber(data),
              style: TextStyle(
                fontSize: isActive ? 28 : 22, // Membesar saat aktif
                fontWeight: FontWeight.w800,
                color: valueColor,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "HEKTAR (HA)",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: subTextColor,
              ),
            ),


            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: isActive ? null : 0, // Tinggi 0 jika tidak aktif
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Divider(color: isActive ? Colors.white24 : Colors.grey.shade100),
                    const SizedBox(height: 12),
                    
                    // Detail Breakdown
                    _buildLegendItem("Produktif", data * 0.65, isActive ? Colors.white : Colors.blue, isActive),
                    const SizedBox(height: 6),
                    _buildLegendItem("Cadangan", data * 0.35, isActive ? Colors.white : Colors.orange, isActive),
                    
                    const SizedBox(height: 12),
                    // Indikator Trend
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white24 : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.trending_up, 
                            color: isActive ? Colors.white : const Color(0xFF166534), 
                            size: 14
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "+2.4% vs lalu",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : const Color(0xFF166534),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, double value, Color color, bool isDarkBg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11, 
            color: isDarkBg ? Colors.white70 : const Color(0xFF64748B)
          ),
        ),
        Text(
          _formatNumber(value),
          style: TextStyle(
            fontSize: 11, 
            fontWeight: FontWeight.bold, 
            color: color
          ),
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}K";
    }
    return number.toStringAsFixed(0);
  }
}