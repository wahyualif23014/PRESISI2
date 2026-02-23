import 'package:flutter/material.dart';
import '../../data/model/land_summary_model.dart';
import '../../data/service/land_potential_service.dart';

class LandSummaryWidget extends StatefulWidget {
  const LandSummaryWidget({super.key});

  @override
  State<LandSummaryWidget> createState() => LandSummaryWidgetState();
}

class LandSummaryWidgetState extends State<LandSummaryWidget> {
  final LandPotentialService _service = LandPotentialService();
  LandSummaryModel? _data;
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchSummaryData();
  }

  Future<void> fetchSummaryData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _service.fetchSummaryData();
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
    if (_isLoading) return _buildLoading();

    if (_data == null || _data!.totalArea <= 0) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.2),
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
                    child: Text(
                      "Total Potensi Lahan ${_formatNumber(_data!.totalArea)} HA",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
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
          if (_isExpanded) _buildExpandedContent(),
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
    child: const CircularProgressIndicator(),
  );

  Widget _buildExpandedContent() {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1, color: Colors.black),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.grey[50],
          child: Text(
            "TERDIRI DARI ${_data!.totalLocations} LOKASI",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Colors.black),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            runSpacing: 16,
            spacing: 8,
            children:
                _data!.categories.map((cat) => _buildCatItem(cat)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCatItem(LandSummaryCategory cat) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cat.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Text(
            "${_formatNumber(cat.area)} HA / ${cat.count} Lokasi",
            style: const TextStyle(fontSize: 11, color: Color(0xFF00838F)),
          ),
        ],
      ),
    );
  }
}
