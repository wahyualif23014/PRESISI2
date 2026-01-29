import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/dashboard/data/model/kwartal_item_model.dart';

class QuarterlyStatsSection extends StatefulWidget {
  final List<QuarterlyItem> items; 

  const QuarterlyStatsSection({super.key, required this.items});

  @override
  State<QuarterlyStatsSection> createState() => _QuarterlyStatsSectionState();
}

class _QuarterlyStatsSectionState extends State<QuarterlyStatsSection> {
  String _selectedPeriod = 'Kwartal 1';

  List<String> get _availablePeriods {
    final periods = widget.items.map((e) => e.period).toSet().toList();
    periods.sort();
    return periods.isNotEmpty ? periods : ['Kwartal 1'];
  }

  List<QuarterlyItem> get _filteredItems {
    return widget.items
        .where((item) => item.period == _selectedPeriod)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Validasi selected period
    if (!_availablePeriods.contains(_selectedPeriod) && _availablePeriods.isNotEmpty) {
      _selectedPeriod = _availablePeriods.first;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER & DROPDOWN ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionHeader(),
              _ElegantDropdown(
                value: _selectedPeriod,
                items: _availablePeriods,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPeriod = val);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- CONTENT GRID ---
          if (_filteredItems.isEmpty)
            const _EmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsif: di mobile 1 kolom, di tablet/web 2 kolom
                final isSmall = constraints.maxWidth < 500;
                final double itemWidth = isSmall 
                    ? constraints.maxWidth 
                    : (constraints.maxWidth - 16) / 2;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _filteredItems.map((item) {
                    return SizedBox(
                      width: itemWidth,
                      child: _QuarterlyItemCard(item: item),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGETS (Clean Architecture Presentation)
// =============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Data Setiap Kwartal",
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B), // Slate 800
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: "Informasi detail per periode kwartal",
          child: Icon(Icons.info_outline_rounded, size: 18, color: Colors.grey[400]),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.folder_off_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            "Data tidak tersedia untuk periode ini",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _ElegantDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _ElegantDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36, // Diperkecil dari 40
      padding: const EdgeInsets.symmetric(horizontal: 4), // Padding lebih rapat
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Radius disesuaikan
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Padding(
            padding: const EdgeInsets.only(left: 4), // Jarak icon lebih dekat
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18, // Ukuran icon diperkecil
              color: Colors.grey[600],
            ),
          ),
          style: const TextStyle(
            color: Color(0xFF334155), // Slate 700
            fontSize: 12, // Font size diperkecil sedikit
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 3,
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _QuarterlyItemCard extends StatelessWidget {
  final QuarterlyItem item;

  const _QuarterlyItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bagian Atas: Value & Period
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Value Besar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatNumber(item.value),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A), // Slate 900
                        height: 1.0,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        item.unit,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8), // Slate 400
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Period Badge Kecil
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2), // Red 50
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFECACA)), // Red 200
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFFEF4444)),
                      const SizedBox(width: 4),
                      Text(
                        item.period,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444), // Red 500
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bagian Bawah: Label Ungu
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF3E8FF), // Purple 100
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Text(
              item.label,
              style: const TextStyle(
                color: Color(0xFF7E22CE), // Purple 700 (Kontras Bagus)
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
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