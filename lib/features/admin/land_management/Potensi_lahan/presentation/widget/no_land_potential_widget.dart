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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
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
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildIconInfo(),
                  const SizedBox(width: 12),
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
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
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

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        "TERDIRI DARI ${_data!.emptyPolsek} POLSEK, ${_data!.emptyKabKota} KAB/KOTA, ${_data!.emptyKecamatan} KECAMATAN, DAN ${_data!.emptyKelDesa} DESA",
        style: const TextStyle(fontSize: 12, height: 1.5),
      ),
    );
  }
}
