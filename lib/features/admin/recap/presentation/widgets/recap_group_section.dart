import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';
import 'recap_data_row.dart';

class RecapGroupSection extends StatefulWidget {
  final RecapModel header;
  final List<RecapModel> children;

  const RecapGroupSection({
    Key? key,
    required this.header,
    required this.children,
  }) : super(key: key);

  @override
  State<RecapGroupSection> createState() => _RecapGroupSectionState();
}

class _RecapGroupSectionState extends State<RecapGroupSection> {
  bool _isExpanded = false; // Default tertutup

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. HEADER (Bagian yang bisa diklik)
        RecapDataRow(
          data: widget.header,
          isExpanded: _isExpanded,
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        
        // 2. CHILDREN (Bagian yang muncul/hilang)
        if (_isExpanded)
          Column(
            children: widget.children.map((childItem) {
              return RecapDataRow(data: childItem);
            }).toList(),
          ),
      ],
    );
  }
}