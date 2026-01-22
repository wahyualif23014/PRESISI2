import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';
import 'recap_data_row.dart'; // Pastikan path import benar

class RecapGroupSection extends StatefulWidget {
  final RecapModel header;
  
  // UBAH: Menggunakan List<Widget> agar bisa menampung nesting (Group dalam Group)
  // Ini memungkinkan struktur: Polres (Group) -> Polsek (Group) -> Desa (Row)
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
  // Jika levelnya Polres, default Expanded (opsional, bisa diubah false)
  // Jika levelnya Polsek, default Collapsed
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    // Contoh logika: Polres default terbuka, Polsek default tertutup
    _isExpanded = widget.header.type == RecapRowType.polres; 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. HEADER ROW (Polres atau Polsek)
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