import 'package:flutter/material.dart';
import '../../data/model/land_summary_model.dart'; // Sesuaikan path
import '../../data/repos/land_summary_repository.dart'; // Sesuaikan path

class LandSummaryWidget extends StatefulWidget {
  const LandSummaryWidget({super.key});

  @override
  State<LandSummaryWidget> createState() => _LandSummaryWidgetState();
}

class _LandSummaryWidgetState extends State<LandSummaryWidget> {
  final LandSummaryRepository _repo = LandSummaryRepository();
  
  LandSummaryModel? _data;
  bool _isLoading = true;
  bool _isExpanded = false; // State untuk kontrol buka/tutup

  @override
  void initState() {
    super.initState();
    _fetchSummaryData();
  }

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
      debugPrint("Error loading summary: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper simpel untuk format angka dengan koma (tanpa package intl)
  String _formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_data == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1), // Border hitam tipis
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded; // Toggle state
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  // Icon Hijau "i"
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 106, 106, 106), // Hijau terang (Lime Green)
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "i",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif', // Agar mirip huruf 'i' di gambar
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Text Header
                  Expanded(
                    child: Text(
                      "Total Potensi Lahan ${_formatNumber(_data!.totalArea)} HA",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900, // Sangat tebal
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Optional: Icon panah agar user tahu bisa diklik
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 2. BODY / DETAIL (MUNCUL JIKA EXPANDED)
          // ==========================================
          if (_isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Colors.black),
            
            // Sub-Header: "Terdiri dari ..."
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Terdiri dari ${_data!.totalLocations} Lokasi Potensi Lahan",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const Divider(height: 1, thickness: 1, color: Colors.black),

            // List Detail Items
            ListView.separated(
              shrinkWrap: true, // Agar list tidak error di dalam Column
              physics: const NeverScrollableScrollPhysics(), // Scroll ikut parent
              itemCount: _data!.details.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1, 
                thickness: 1, 
                color: Colors.black54
              ),
              itemBuilder: (context, index) {
                final item = _data!.details[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Kiri: Judul (Milik Polri, dll)
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      // Kanan: Angka (6.59 HA/5 LOKASI)
                      Text(
                        "${item.area} HA/${item.locationCount} LOKASI",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Padding bawah sedikit agar rapi
            const SizedBox(height: 4),
          ]
        ],
      ),
    );
  }
}