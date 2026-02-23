import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';

class KelolaSummaryWidget extends StatefulWidget {
  const KelolaSummaryWidget({super.key});

  @override
  State<KelolaSummaryWidget> createState() => KelolaSummaryWidgetState();
}

class KelolaSummaryWidgetState extends State<KelolaSummaryWidget> {
  bool _isExpanded = false;

  // Inisialisasi variabel dengan nama yang konsisten
  double potensi = 0;
  double tanam = 0;
  double panen = 0;
  double hasil = 0;

  // Fungsi sinkronisasi data yang dipanggil dari KelolaLahanPage
  void calculateSummaryFromList(List<LandManagementItemModel> list) {
    double tPot = 0;
    double tTan = 0;
    double tPan = 0;
    double tHas = 0;

    for (var item in list) {
      tPot += item.landArea;
      tTan += item.luasTanam;
      tPan += item.luasPanen;
      tHas += item.hasilPanen;
    }

    setState(() {
      potensi = tPot;
      tanam = tTan;
      panen = tPan;
      hasil = tHas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: Column(
        children: [
          // Header Summary yang bisa diklik
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildIconInfo(),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Ringkasan Pengelolaan Lahan",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // Konten yang muncul saat di-expand
          if (_isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Colors.black),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                runSpacing: 12,
                children: [
                  _buildSummaryItem(
                    "TOTAL POTENSI",
                    "${potensi.toStringAsFixed(2)} HA",
                    const Color(0xFF64748B),
                  ),
                  _buildSummaryItem(
                    "TOTAL TANAM",
                    "${tanam.toStringAsFixed(2)} HA",
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    "LUAS PANEN",
                    "${panen.toStringAsFixed(2)} HA", // Memperbaiki 'pan' menjadi 'panen'
                    Colors.orange,
                  ),
                  _buildSummaryItem(
                    "TOTAL HASIL",
                    "${hasil.toStringAsFixed(2)} TON",
                    Colors.deepPurple,
                  ),
                ],
              ),
            ),
          ],
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
          fontStyle: FontStyle.italic,
          fontSize: 18,
        ),
      ),
    ),
  );

  Widget _buildSummaryItem(String label, String value, Color color) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 80) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
