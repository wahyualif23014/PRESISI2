import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/riwayat_lahan/data/repos/lahan_history_repos.dart';

class FilterriwayatDialog extends StatefulWidget {
  final Function(Map<String, String> filters) onApply;
  final VoidCallback onReset;

  const FilterriwayatDialog({
    super.key,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterriwayatDialog> createState() => _FilterriwayatDialogState();
}

class _FilterriwayatDialogState extends State<FilterriwayatDialog> {
  final LandHistoryRepository _repo = LandHistoryRepository();
  bool _isLoading = true;

  List<String> _listPolres = [];
  List<String> _listPolsek = [];
  List<String> _listJenisLahan = [];
  List<String> _listkomoditi = [];

  String? _selectedPolres;
  String? _selectedPolsek;
  String? _selectedJenisLahan;
  String? _selectedkomoditi;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // 1. Load data awal: Polres, Jenis Lahan, dan komoditi (Hanya sekali)
  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = await _repo.getFilterOptions();

      if (!mounted) return;

      setState(() {
        _listPolres = (data['polres'] ?? []).toSet().toList();
        _listJenisLahan = (data['jenis_lahan'] ?? []).toSet().toList();
        _listkomoditi = (data['komoditi'] ?? []).toSet().toList();

        _listPolsek = []; // ⛔ kosongin dulu
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error initial load: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Load Polsek secara cascading saat Polres dipilih
  Future<void> _loadPolsek(String polres) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _listPolsek = [];
    });

    try {
      final data = await _repo.getFilterOptions(polres: polres);

      if (!mounted) return;

      setState(() {
        _listPolsek = (data['polsek'] ?? []).toSet().toList();
        _isLoading = false;
      });

      debugPrint("Polsek loaded: $_listPolsek"); // cek isi
    } catch (e) {
      debugPrint("Error load polsek: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ), // Lebih bulat
      elevation: 10,
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.filter_list_rounded,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Filter Riwayat",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDropdown(
                      label: "Kepolisian Resor",
                      hint: "Pilih Polres",
                      value: _selectedPolres,
                      items: _listPolres,
                      icon: Icons.account_balance,
                      onChanged: (val) {
                        setState(() {
                          _selectedPolres = val;
                          _selectedPolsek = null;
                          _listPolsek = [];
                        });
                        if (val != null) _loadPolsek(val);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: "Kepolisian Sektor",
                      hint: "Pilih Polsek",
                      value: _selectedPolsek,
                      items: _listPolsek,
                      icon: Icons.location_city,
                      onChanged:
                          _selectedPolres == null
                              ? null
                              : (val) => setState(() => _selectedPolsek = val),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: "Jenis Lahan",
                      hint: "Pilih Jenis Lahan",
                      value: _selectedJenisLahan,
                      items: _listJenisLahan,
                      icon: Icons.landscape,
                      onChanged:
                          (val) => setState(() => _selectedJenisLahan = val),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: "Komoditi",
                      hint: "Pilih Komoditi",
                      value: _selectedkomoditi,
                      items: _listkomoditi,
                      icon: Icons.grass,
                      onChanged:
                          (val) => setState(() => _selectedkomoditi = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      widget.onReset();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                    child: const Text("Reset Filter"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply({
                        'polres': _selectedPolres ?? '',
                        'polsek': _selectedPolsek ?? '',
                        'jenis_lahan': _selectedJenisLahan ?? '',
                        'komoditi': _selectedkomoditi ?? '',
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Terapkan"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
    required IconData icon,
  }) {
    final uniqueItems = items.toSet().toList();
    bool isDisabled = onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDisabled
                      ? Colors.grey[300]!
                      : Colors.deepPurple.withOpacity(0.3),
            ),
            boxShadow: [
              if (!isDisabled)
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: uniqueItems.contains(value) ? value : null,
              hint: Text(
                hint,
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDisabled ? Colors.grey : Colors.deepPurple,
              ),
              items:
                  uniqueItems
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
