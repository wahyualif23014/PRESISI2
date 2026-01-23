import 'package:flutter/material.dart';
import '../../data/model/no_land_potential_model.dart'; // Sesuaikan path
import '../../data/repos/no_land_potential_repository.dart'; // Sesuaikan path

class NoLandPotentialWidget extends StatefulWidget {
  const NoLandPotentialWidget({super.key});

  @override
  State<NoLandPotentialWidget> createState() => _NoLandPotentialWidgetState();
}

class _NoLandPotentialWidgetState extends State<NoLandPotentialWidget> {
  final NoLandPotentialRepository _repo = NoLandPotentialRepository();
  
  NoLandPotentialModel? _data;
  bool _isLoading = true;
  bool _isExpanded = false; // State buka/tutup

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
    if (_isLoading) {
      return const SizedBox(height: 50); // Placeholder saat loading
    }

    if (_data == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1), // Border hitam
      ),
      child: Column(
        children: [
          // ==========================================
          // 1. HEADER (CLICKABLE)
          // ==========================================
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  // Icon "i" Hijau
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00FF00), // Hijau terang
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "i",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text Judul
                  Expanded(
                    child: Text(
                      "Total ${_data!.totalPolres} Polres tidak ada potensi lahan",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900, // Tebal sekali
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Icon Panah Indikator
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 2. BODY (LIST RINCIAN)
          // ==========================================
          if (_isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Colors.black),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                      // Label (Kiri)
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      // Value (Kanan)
                      Text(
                        "${item.count} LOKASI",
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
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}