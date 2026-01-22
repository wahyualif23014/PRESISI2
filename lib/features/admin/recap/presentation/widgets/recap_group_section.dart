import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';
import 'recap_data_row.dart'; // Pastikan path import benar

class RecapGroupSection extends StatefulWidget {
  final RecapModel header;
  final List<Widget> children; 

  const RecapGroupSection({
    Key? key,
    required this.header,
    required this.children,
  }) : super(key: key);

  @override
  State<RecapGroupSection> createState() => _RecapGroupSectionState();
}

class _RecapGroupSectionState extends State<RecapGroupSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.header.type == RecapRowType.polres; 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecapDataRow(
          data: widget.header,
          isExpanded: _isExpanded,
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded; // Toggle Buka/Tutup
            });
          },
        ),


        if (_isExpanded)
          Column(
            children: widget.children,
          ),
      ],
    );
  }
}