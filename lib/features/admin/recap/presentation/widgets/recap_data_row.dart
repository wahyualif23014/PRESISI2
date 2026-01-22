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

  // --- LOGIC HELPER ---

  bool get _isPolres => data.type == RecapRowType.polres;
  bool get _isPolsek => data.type == RecapRowType.polsek;
  bool get _isDesa => data.type == RecapRowType.desa;

  // 1. Warna Background
  Color get _backgroundColor {
    if (_isPolres) return const Color(0xFFE0E0F8);
    if (_isPolsek) return const Color(0xFFF3F3FF);
    return Colors.white;
  }

  FontWeight get _fontWeight {
    if (_isPolres) return FontWeight.w800;
    if (_isPolsek) return FontWeight.w600;
    return FontWeight.w400;
  }

  double get _indent {
    if (_isPolsek) return 16.0;
    if (_isDesa) return 32.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: _fontWeight,
      color: Colors.black87,
    );

    final bool isExpandable = !_isDesa;

    return Material(
      color: _backgroundColor,
      child: InkWell(
        onTap: isExpandable ? onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: _indent),

                    // Teks Nama Wilayah
                    Expanded(
                      child: Text(
                        data.namaWilayah,
                        style: textStyle,
                        maxLines: 3, 
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. DATA ANGKA ---
              _buildDataCell("${data.potensiLahan.toInt()} HA", textStyle),
              _buildDataCell("${data.tanamLahan.toInt()} HA", textStyle),
              _buildDataCell(data.panenDisplay, textStyle, flex: 3),
              _buildDataCell("${data.serapan.toInt()} HA", textStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextStyle style, {int flex = 2}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}