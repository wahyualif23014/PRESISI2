import 'package:flutter/material.dart';
import '../../data/model/quarterly_item_model.dart';

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
    return widget.items.where((item) => item.period == _selectedPeriod).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Safety check: Pastikan pilihan saat ini ada di daftar periode yang tersedia
    if (!_availablePeriods.contains(_selectedPeriod) && _availablePeriods.isNotEmpty) {
      _selectedPeriod = _availablePeriods.first;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    "Data Setiap Kwartal",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.info_outline, size: 18, color: Colors.red[400]),
                ],
              ),
              _buildDropdown(),
            ],
          ),

          const SizedBox(height: 20),

          // Content Grid
          if (_filteredItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text("Data tidak tersedia untuk periode ini")),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final double itemWidth = (constraints.maxWidth - 16) / 2;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _filteredItems.map((item) {
                    return SizedBox(
                      width: constraints.maxWidth < 600 ? constraints.maxWidth : itemWidth,
                      child: _buildItemCard(item),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey[600]),
          style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
          items: _availablePeriods.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedPeriod = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildItemCard(QuarterlyItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Value & Unit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatNumber(item.value),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        item.unit,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Period Badge
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      item.period,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Bottom Label
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF3E8FF),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            child: Text(
              item.label,
              style: const TextStyle(
                color: Color(0xFF9333EA),
                fontWeight: FontWeight.w500,
                fontSize: 12,
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
    return number % 1 == 0 ? number.toInt().toString() : number.toString();
  }
}