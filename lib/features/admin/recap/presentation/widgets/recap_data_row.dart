import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';

class RecapDataRow extends StatelessWidget {
  final RecapModel data;
  final VoidCallback? onTap;
  final bool isExpanded;

  const RecapDataRow({
    Key? key,
    required this.data,
    this.onTap,
    this.isExpanded = false,
  }) : super(key: key);

  bool get _isPolres => data.type == RecapRowType.polres;
  bool get _isPolsek => data.type == RecapRowType.polsek;
  bool get _isDesa => data.type == RecapRowType.desa;

  Color get _backgroundColor {
    if (_isPolres) return const Color(0xFFEFF6FF);
    if (_isPolsek) return const Color(0xFFF8FAFC);
    return Colors.white;
  }

  double get _indent {
    if (_isPolsek) return 16.0;
    if (_isDesa) return 32.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpandable = !_isDesa;
    
    final baseStyle = TextStyle(
      fontSize: 12,
      color: Colors.black87,
      height: 1.3,
      fontWeight: _isDesa ? FontWeight.w400 : FontWeight.w600,
    );

    return Material(
      color: _backgroundColor,
      child: InkWell(
        onTap: isExpandable ? onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60), 
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    SizedBox(width: _indent),
                    if (isExpandable)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AnimatedRotation(
                          turns: isExpanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            Icons.arrow_right_rounded, 
                            size: 20, 
                            color: _isPolres ? const Color(0xFF1E40AF) : Colors.grey.shade700,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 28),
                    
                    Expanded(
                      child: Text(
                        data.namaWilayah,
                        style: baseStyle.copyWith(
                          color: _isPolres ? const Color(0xFF1E40AF) : Colors.black87,
                          fontSize: _isPolres ? 13 : 12,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDataCell("${data.potensiLahan.toInt()} HA", baseStyle, flex: 2),
              _buildDataCell("${data.tanamLahan.toInt()} HA", baseStyle, flex: 2),
              _buildDataCell(data.panenDisplay, baseStyle, flex: 3),
              _buildDataCell("${data.serapan.toInt()}%", baseStyle, flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextStyle style, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          style: style,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}