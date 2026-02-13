import 'package:flutter/material.dart';
import '../../data/model/land_potential_model.dart';

class LandDetailDialog extends StatelessWidget {
  final LandPotentialModel data;

  const LandDetailDialog({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER CUSTOM
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF0097B2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  "Detail Informasi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // BODY SCROLLABLE
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _infoSection(
                    "DATA LAHAN",
                    Icons.landscape,
                    Colors.green.shade700,
                    [
                      _row("Alamat", data.alamatLahan),
                      _row("Luas", "${data.luasLahan} HA"),
                      _row("Jenis", data.jenisLahan),
                      _row(
                        "Komoditi",
                        data.komoditi.isEmpty ? "-" : data.komoditi,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoSection(
                    "PERSONEL",
                    Icons.badge_outlined,
                    Colors.blue.shade700,
                    [
                      _row(
                        "Polisi",
                        "${data.policeName}\n(${data.policePhone})",
                      ),
                      _row("PJ Lahan", "${data.picName}\n(${data.picPhone})"),
                      _row("Poktan", data.keterangan),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoSection(
                    "WILAYAH",
                    Icons.map_outlined,
                    Colors.orange.shade700,
                    [
                      _row("Kabupaten", data.kabupaten),
                      _row("Kecamatan", data.kecamatan),
                      _row("Desa", data.desa),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...items,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
