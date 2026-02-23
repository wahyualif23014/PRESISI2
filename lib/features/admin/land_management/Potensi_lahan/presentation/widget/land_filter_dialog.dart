import 'package:flutter/material.dart';
import '../../data/service/land_potential_service.dart';

class LandFilterDialog extends StatefulWidget {
  final Function(Map<String, String> filters) onApply;
  final VoidCallback onReset;

  const LandFilterDialog({
    super.key,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<LandFilterDialog> createState() => _LandFilterDialogState();
}

class _LandFilterDialogState extends State<LandFilterDialog> {
  final LandPotentialService _service = LandPotentialService();
  bool _isLoading = true;

  List<String> _listPolres = [];
  List<String> _listPolsek = [];
  String? _selPolres, _selPolsek, _selJenis;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final data = await _service.fetchFilterOptions();
    setState(() {
      _listPolres = data['polres'] ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter Potensi Lahan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    _buildDrop("Kepolisian Resor", _listPolres, _selPolres, (
                      v,
                    ) async {
                      setState(() {
                        _selPolres = v;
                        _selPolsek = null;
                        _isLoading = true;
                      });
                      final data = await _service.fetchFilterOptions(polres: v);
                      setState(() {
                        _listPolsek = data['polsek'] ?? [];
                        _isLoading = false;
                      });
                    }),
                    const SizedBox(height: 12),
                    _buildDrop(
                      "Kepolisian Sektor",
                      _listPolsek,
                      _selPolsek,
                      (v) => setState(() => _selPolsek = v),
                    ),
                    const SizedBox(height: 12),
                    _buildDrop(
                      "Jenis Lahan",
                      ["SAWAH", "LADANG", "PERKEBUNAN"],
                      _selJenis,
                      (v) => setState(() => _selJenis = v),
                    ),
                  ],
                ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0097B2),
                    ),
                    onPressed: () {
                      widget.onApply({
                        'polres': _selPolres ?? '',
                        'polsek': _selPolsek ?? '',
                        'jenis_lahan': _selJenis ?? '',
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Terapkan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onReset();
                      Navigator.pop(context);
                    },
                    child: const Text("Reset"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrop(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
