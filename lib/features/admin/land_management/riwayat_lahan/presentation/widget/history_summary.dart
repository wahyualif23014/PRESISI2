import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/models/lahan_history_model.dart';

class HistorySummary extends StatefulWidget {
  final LandHistorySummaryModel? data;
  final bool isLoading;

  const HistorySummary({super.key, required this.data, this.isLoading = false});

  @override
  State<HistorySummary> createState() => _HistorySummaryState();
}

class _HistorySummaryState extends State<HistorySummary> {
  // State untuk mengontrol expand/collapse tiap kategori
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
    if (widget.isLoading) return _buildLoading();

    if (widget.data == null) return const SizedBox();

    return Column(
      children: [
        // 1. KATEGORI DETAIL POTENSI LAHAN
        _buildCategoryCard(
          title:
              "Total Potensi Lahan ${_formatNumber(widget.data!.totalPotensiLahan)} HA",
          isExpanded: _isPotensiExpanded,
          onTap: () => setState(() => _isPotensiExpanded = !_isPotensiExpanded),
          locationCount: "5130", // Ganti dinamis jika ada di model
          details: [
            {'title': 'MILIK POLRI', 'area': 8.13, 'count': 11},
            {'title': 'POKTAN BINAAN POLRI', 'area': 33578.51, 'count': 971},
            {
              'title': 'MASYARAKAT BINAAN POLRI',
              'area': 27290.38,
              'count': 584,
            },
            {'title': 'TUMPANG SARI', 'area': 208.94, 'count': 42},
            {'title': 'PERHUTANAN SOSIAL', 'area': 19802.41, 'count': 208},
            {'title': 'PERHUTANI/INHUTANI', 'area': 10627.53, 'count': 131},
            {'title': 'PESANTREN', 'area': 134.50, 'count': 62},
            {'title': 'LBS', 'area': 50537.24, 'count': 3088},
            {'title': 'LAINNYA', 'area': 106.02, 'count': 33},
          ],
        ),

        // 2. KATEGORI DETAIL TANAM LAHAN
        _buildCategoryCard(
          title:
              "Total Tanam Lahan ${_formatNumber(widget.data!.totalTanamLahan)} HA",
          isExpanded: _isTanamExpanded,
          onTap: () => setState(() => _isTanamExpanded = !_isTanamExpanded),
          locationCount: "0",
          details: [
            {'title': 'MILIK POLRI', 'area': 0.0, 'count': 0},
            {'title': 'POKTAN BINAAN POLRI', 'area': 0.0, 'count': 0},
            {'title': 'MASYARAKAT BINAAN POLRI', 'area': 0.0, 'count': 0},
          ],
        ),

        // 3. KATEGORI DETAIL PANEN LAHAN
        _buildCategoryCard(
          title:
              "Total Panen Lahan ${_formatNumber(widget.data!.totalPanenLahanHa)} HA",
          isExpanded: _isPanenExpanded,
          onTap: () => setState(() => _isPanenExpanded = !_isPanenExpanded),
          locationCount: "0",
          details: [
            {
              'title': 'HASIL PANEN',
              'area': widget.data!.totalPanenLahanTon,
              'count': 0,
            },
          ],
        ),

        // 4. KATEGORI DETAIL SERAPAN
        _buildCategoryCard(
          title:
              "Total Serapan ${_formatNumber(widget.data!.totalSerapanTon)} TON",
          isExpanded: _isSerapanExpanded,
          onTap: () => setState(() => _isSerapanExpanded = !_isSerapanExpanded),
          locationCount: "0",
          details: [
            {
              'title': 'TOTAL SERAPAN',
              'area': widget.data!.totalSerapanTon,
              'count': 0,
            },
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
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
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
                    children: details.map((cat) => _buildCatItem(cat)).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCatItem(Map<String, dynamic> cat) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cat['title'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Text(
            "${_formatNumber(cat['area'])} HA / ${cat['count']} Lokasi",
            style: const TextStyle(fontSize: 11, color: Color(0xFF00838F)),
          ),
        ],
      ),
    );
  }

  Widget _buildIconInfo() => Container(
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

  Widget _buildLoading() => Container(
    height: 60,
    alignment: Alignment.center,
    child: const CircularProgressIndicator(color: Colors.black),
  );
}
