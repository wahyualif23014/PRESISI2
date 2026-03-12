import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/providers/land_history_provider.dart' show LandHistoryProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistorySummary extends StatefulWidget {
  const HistorySummary({super.key});

  @override
  State<HistorySummary> createState() => _HistorySummaryState();
}

class _HistorySummaryState extends State<HistorySummary> {

  bool _isPotensiExpanded = false;
  bool _isTanamExpanded = false;
  bool _isPanenExpanded = false;
  bool _isSerapanExpanded = false;

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

    final provider = context.watch<LandHistoryProvider>();
    final summary = provider.summary;

    if (provider.isLoading) {
      return _buildLoading();
    }

    return Column(
      children: [

        // ================= POTENSI =================

        _buildCategoryCard(
          title:
              "Total Potensi Lahan ${_formatNumber(summary.totalPotensiLahan)} HA",
          isExpanded: _isPotensiExpanded,
          onTap: () => setState(() => _isPotensiExpanded = !_isPotensiExpanded),
          locationCount: "-", // backend belum kirim lokasi
          details: [
            {
              "title": "TOTAL POTENSI",
              "area": summary.totalPotensiLahan,
              "count": "-"
            }
          ],
        ),

        // ================= TANAM =================

        _buildCategoryCard(
          title:
              "Total Tanam Lahan ${_formatNumber(summary.totalTanamLahan)} HA",
          isExpanded: _isTanamExpanded,
          onTap: () => setState(() => _isTanamExpanded = !_isTanamExpanded),
          locationCount: "-",
          details: [
            {
              "title": "TOTAL TANAM",
              "area": summary.totalTanamLahan,
              "count": "-"
            }
          ],
        ),

        // ================= PANEN =================

        _buildCategoryCard(
          title:
              "Total Panen Lahan ${_formatNumber(summary.totalPanenLahanHa)} HA",
          isExpanded: _isPanenExpanded,
          onTap: () => setState(() => _isPanenExpanded = !_isPanenExpanded),
          locationCount: "-",
          details: [
            {
              "title": "HASIL PANEN (TON)",
              "area": summary.totalPanenLahanTon,
              "count": "-"
            }
          ],
        ),

        // ================= SERAPAN =================

        _buildCategoryCard(
          title:
              "Total Serapan ${_formatNumber(summary.totalSerapanTon)} TON",
          isExpanded: _isSerapanExpanded,
          onTap: () => setState(() => _isSerapanExpanded = !_isSerapanExpanded),
          locationCount: "-",
          details: [
            {
              "title": "TOTAL SERAPAN",
              "area": summary.totalSerapanTon,
              "count": "-"
            }
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required String locationCount,
    required List<Map<String, dynamic>> details,
  }) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: Column(
        children: [

          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [

                  _buildIconInfo(),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),

          if (isExpanded)
            Column(
              children: [

                const Divider(height: 1, thickness: 1, color: Colors.black),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[50],
                  child: Text(
                    "TERDIRI DARI $locationCount LOKASI",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),

                const Divider(height: 1, thickness: 1, color: Colors.black),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    runSpacing: 16,
                    spacing: 8,
                    children:
                        details.map((cat) => _buildCatItem(cat)).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCatItem(Map<String, dynamic> cat) {

    final area = cat['area'] is double
        ? cat['area']
        : double.tryParse(cat['area'].toString()) ?? 0;

    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            cat['title'].toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            "${_formatNumber(area)}",
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF00838F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconInfo() {
    return Container(
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
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: Colors.black),
    );
  }
}