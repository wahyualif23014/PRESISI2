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

  final List<String> _listJenis = [
    "Perhutanan Sosial",
    "Poktan Binaan Polri",
    "Masyarakat Binaan Polri",
    "Tumpang Sari",
    "Milik Polri",
    "LBS",
    "Pesantren",
    "Lahan Lainnya",
  ];

  String? _selPolres, _selPolsek, _selJenis;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final data = await _service.fetchFilterOptions();
    setState(() {
      _listPolres = List<String>.from(data['polres'] ?? []);
      _isLoading = false;
    });
  }

  Future<void> _loadPolsek(String? polres) async {
    if (polres == null) return;

    setState(() {
      _isLoading = true;
      _selPolsek = null;
    });

    final data = await _service.fetchFilterOptions(polres: polres);

    setState(() {
      _listPolsek = List<String>.from(data['polsek'] ?? []);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list_rounded, color: Color(0xFF0097B2)),
                const SizedBox(width: 10),
                const Text(
                  "Filter Potensi Lahan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 32, thickness: 1),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF0097B2)),
                ),
              )
            else ...[
              // Dropdown Kepolisian Resor
              _listPolres.isEmpty
                  ? _buildEmptyState("Data Polres tidak ada")
                  : _buildDrop(
                    label: "Kepolisian Resor",
                    icon: Icons.account_balance,
                    // Menggunakan .toSet().toList() untuk memastikan tidak ada nama Polres yang duplikat
                    items: _listPolres.toSet().toList(),
                    // Memastikan value yang terpilih ada di dalam list agar tidak error assertion
                    value: _listPolres.contains(_selPolres) ? _selPolres : null,
                    onChanged: (v) {
                      setState(() {
                        _selPolres = v;
                        _selPolsek = null;
                        _isLoading = true;
                      });
                      _loadPolsek(v);
                    },
                  ),
              const SizedBox(height: 16),

              // Dropdown Kepolisian Sektor
              _selPolres != null && _listPolsek.isEmpty
                  ? _buildEmptyState("Data Polsek tidak ada")
                  : _buildDrop(
                    label: "Kepolisian Sektor",
                    icon: Icons.location_city,
                    // Menggunakan .toSet().toList() agar daftar Polsek unik
                    items: _listPolsek.toSet().toList(),
                    value: _listPolsek.contains(_selPolsek) ? _selPolsek : null,
                    onChanged: (v) => setState(() => _selPolsek = v),
                    enabled: _selPolres != null,
                  ),
              const SizedBox(height: 16),

              // Dropdown Jenis Lahan
              _buildDrop(
                label: "Jenis Lahan",
                icon: Icons.landscape,
                items: _listJenis.toSet().toList(),
                value: _listJenis.contains(_selJenis) ? _selJenis : null,
                onChanged: (v) => setState(() => _selJenis = v),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      widget.onReset();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Reset",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF0097B2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0097B2).withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF0097B2).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            "👮‍♂️", // Icon Polisi
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          const Text(
            "Lapor Komandan!",
            style: TextStyle(
              color: Color(0xFF0097B2),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$message tidak ditemukan. Kosong 8-6!",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDrop({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.black87 : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            "Pilih ${label.split(' ').last}",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
          items:
              items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 20,
              color: enabled ? const Color(0xFF0097B2) : Colors.grey,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: !enabled,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0097B2),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
