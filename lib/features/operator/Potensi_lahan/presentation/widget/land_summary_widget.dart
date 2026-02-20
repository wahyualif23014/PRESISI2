import 'package:flutter/material.dart';
import '../../data/model/land_summary_model.dart';
import '../../data/repos/land_summary_repository.dart';

class LandSummaryWidget extends StatefulWidget {
  const LandSummaryWidget({super.key});

  @override
  State<LandSummaryWidget> createState() => _LandSummaryWidgetState();
}

class _LandSummaryWidgetState extends State<LandSummaryWidget> {
  final LandSummaryRepository _repo = LandSummaryRepository();

  LandSummaryModel? _data;
  bool _isLoading = true;
  bool _isExpanded = false; // Default tertutup

  @override
  void initState() {
    super.initState();
    _fetchSummaryData();
  }

  // Ambil data dari API
  Future<void> _fetchSummaryData() async {
    try {
      final data = await _repo.getSummaryData();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Format Angka: 1234.56 -> 1,234.56
  String _formatNumber(double number) {
    return number
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Loading State
    if (_isLoading) {
      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // 2. Empty/Error State
    if (_data == null) return const SizedBox();

    // 3. Data Loaded
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        children: [
          // HEADER (BISA DIKLIK)
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
                  // ICON "i" HIJAU
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

                  // TEXT UTAMA
                  Expanded(
                    child: Text(
                      "Total Potensi Lahan ${_formatNumber(_data!.totalArea)} HA",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // ICON PANAH
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

          // BODY (EXPANDABLE)
          if (_isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Colors.black),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[50],
              child: Text(
                "TERDIRI DARI ${_data!.totalLocations} LOKASI POTENSI LAHAN",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Colors.black),

            // DETAIL KATEGORI (2 KOLOM)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 0,
                runSpacing: 16,
                children:
                    _data!.categories.map((cat) {
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 64) / 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.title,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: _formatNumber(cat.area),
                                    style: const TextStyle(
                                      color: Color(0xFF00838F),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: " HA / "),
                                  TextSpan(
                                    text: "${cat.count}",
                                    style: const TextStyle(
                                      color: Color(0xFF0277BD),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: " LOKASI"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),

            const Divider(height: 1, thickness: 0.5, color: Colors.grey),

            // BAGIAN FOOTER ADMINISTRASI
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  _buildAdminItem(
                    "POLRES",
                    "${_data!.adminCounts.polres} LOKASI",
                  ),
                  _buildAdminItem(
                    "POLSEK",
                    "${_data!.adminCounts.polsek} LOKASI",
                  ),
                  _buildAdminItem(
                    "KAB./KOTA",
                    "${_data!.adminCounts.kabKota} LOKASI",
                  ),
                  _buildAdminItem(
                    "KECAMATAN",
                    "${_data!.adminCounts.kecamatan} LOKASI",
                  ),
                  _buildAdminItem(
                    "KEL./DESA",
                    "${_data!.adminCounts.kelDesa} LOKASI",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  // --- HELPER UNTUK ITEM ADMINISTRASI ---
  Widget _buildAdminItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF0277BD),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
