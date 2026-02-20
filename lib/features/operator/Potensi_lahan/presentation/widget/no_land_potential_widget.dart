import 'package:flutter/material.dart';
import '../../data/model/no_land_potential_model.dart';
import '../../data/repos/no_land_potential_repository.dart';

class NoLandPotentialWidget extends StatefulWidget {
  const NoLandPotentialWidget({super.key});

  @override
  State<NoLandPotentialWidget> createState() => _NoLandPotentialWidgetState();
}

class _NoLandPotentialWidgetState extends State<NoLandPotentialWidget> {
  final NoLandPotentialRepository _repo = NoLandPotentialRepository();

  NoLandPotentialModel? _data;
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _repo.getNoLandData();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading no land data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Loading State
    if (_isLoading) {
      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // 2. Empty State
    if (_data == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        children: [
          // HEADER
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Icon "i" Hijau
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF9E9D24),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "i",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                          fontStyle: FontStyle.italic,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text Judul
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: "TOTAL "),
                          TextSpan(
                            text: "${_data!.totalEmptyPolres}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: Color(0xFF00838F),
                            ),
                          ),
                          const TextSpan(
                            text: " POLRES TIDAK ADA POTENSI LAHAN",
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Icon Panah
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // BODY (RINCIAN DALAM BENTUK TEKS BARIS)
          if (_isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Colors.black),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: "TERDIRI DARI "),
                      _boldValue("${_data!.emptyPolsek}", " POLSEK, "),
                      _boldValue("${_data!.emptyKabKota}", " KAB./KOTA, "),
                      _boldValue("${_data!.emptyKecamatan}", " KECAMATAN, "),
                      const TextSpan(text: "DAN "),
                      _boldValue("${_data!.emptyKelDesa}", " KEL./DESA"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper untuk membuat teks angka berwarna dan tebal
  TextSpan _boldValue(String val, String suffix) {
    return TextSpan(
      children: [
        TextSpan(
          text: val,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF00838F),
          ),
        ),
        TextSpan(text: suffix),
      ],
    );
  }
}
