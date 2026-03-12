import 'package:flutter/material.dart';
import '../../data/model/no_land_potential_model.dart';
import '../../data/service/land_potential_service.dart';

class NoLandPotentialWidget extends StatefulWidget {
  const NoLandPotentialWidget({super.key});

  @override
  State<NoLandPotentialWidget> createState() => NoLandPotentialWidgetState();
}

class NoLandPotentialWidgetState extends State<NoLandPotentialWidget> {
  final LandPotentialService _service = LandPotentialService();
  NoLandPotentialModel? _data;
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fungsi untuk mengambil data dari server
  Future<void> fetchData() async {
    try {
      final data = await _service.fetchNoLandData();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch No Land: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // Jika data kosong atau nol semua, widget tidak ditampilkan
    if (_data == null || _data!.totalEmptyPolres == 0) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _buildIconInfo(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          const TextSpan(text: "INFO: "),
                          TextSpan(
                            text: "${_data!.totalEmptyPolres}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.redAccent,
                              fontSize: 15,
                            ),
                          ),
                          const TextSpan(
                            text: " POLRES BELUM MEMILIKI POTENSI LAHAN",
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) _buildDetails(),
        ],
      ),
    );
  }

  // Ikon informasi dengan warna yang lebih lembut
  Widget _buildIconInfo() => Container(
    width: 28,
    height: 28,
    decoration: BoxDecoration(
      color: Colors.orange.shade800,
      shape: BoxShape.circle,
    ),
    child: const Center(
      child: Icon(Icons.priority_high_rounded, color: Colors.white, size: 16),
    ),
  );

  // Bagian detail wilayah yang belum terisi
  Widget _buildDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "RINCIAN WILAYAH KOSONG:",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSmallChip("Polsek", _data!.emptyPolsek),
              _buildSmallChip("Kecamatan", _data!.emptyKecamatan),
              _buildSmallChip("Desa/Kel", _data!.emptyKelDesa),
            ],
          ),
        ],
      ),
    );
  }

  // Widget pembantu untuk menampilkan angka rincian dalam bentuk chip
  Widget _buildSmallChip(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          Text(
            "$count",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
