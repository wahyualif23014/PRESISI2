import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';
import 'recap_data_row.dart';

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
              _isExpanded = !_isExpanded;
            });
          },
        ),
        AnimatedCrossFade(
          firstChild: Container(),
          secondChild: Column(children: widget.children),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }
}