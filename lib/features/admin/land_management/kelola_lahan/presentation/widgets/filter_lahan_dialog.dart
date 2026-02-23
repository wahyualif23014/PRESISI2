import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/repos/kelola_repo.dart';

class FilterLahanDialog extends StatefulWidget {
  final Function(Map<String, String> filters) onApply;
  final VoidCallback onReset;

  const FilterLahanDialog({
    super.key,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterLahanDialog> createState() => _FilterLahanDialogState();
}

class _FilterLahanDialogState extends State<FilterLahanDialog> {
  final LandManagementRepository _repo = LandManagementRepository();
  bool _isLoading = true;

  // Data List Dropdown
  List<String> _listPolres = [];
  List<String> _listPolsek = [];
  List<String> _listJenisLahan = [];
  List<String> _listKomoditas = [];

  // Nilai Terpilih
  String? _selectedPolres;
  String? _selectedPolsek;
  String? _selectedJenisLahan;
  String? _selectedKomoditas;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Load awal (Hanya Polres yang full, sisanya kosong/menyesuaikan)
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final data = await _repo.getFilterOptions();
    if (mounted) {
      setState(() {
        _listPolres = data['polres'] ?? [];
        _isLoading = false;
      });
    }
  }

  // Load cascading (saat Polres dipilih, load Polsek)
  Future<void> _onPolresChanged(String? val) async {
    setState(() {
      _selectedPolres = val;
      _selectedPolsek = null; // Reset anak-anaknya
      _selectedJenisLahan = null;
      _selectedKomoditas = null;
      _listPolsek = []; // Kosongkan dulu
      _isLoading = true;
    });

    if (val != null) {
      final data = await _repo.getFilterOptions(polres: val);
      if (mounted) {
        setState(() {
          _listPolsek = data['polsek'] ?? [];
          // Jenis lahan & komoditas juga bisa berubah sesuai wilayah
          _listJenisLahan = data['jenis_lahan'] ?? [];
          _listKomoditas = data['komoditas'] ?? [];
          _isLoading = false;
        });
      }
    } else {
      // Jika di-unselect, reset ke awal
      _loadInitialData();
    }
  }

  // Load cascading (saat Polsek dipilih)
  Future<void> _onPolsekChanged(String? val) async {
    setState(() {
      _selectedPolsek = val;
      _isLoading = true;
    });

    if (val != null) {
      final data = await _repo.getFilterOptions(
        polres: _selectedPolres,
        polsek: val,
      );
      if (mounted) {
        setState(() {
          _listJenisLahan = data['jenis_lahan'] ?? [];
          _listKomoditas = data['komoditas'] ?? [];
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        // Agar aman di layar kecil
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filter Data Lahan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const Divider(height: 30),

              // 1. KEPOLISIAN RESOR (POLRES)
              _buildDropdown(
                label: "Kepolisian Resor",
                hint: "Pilih Polres",
                value: _selectedPolres,
                items: _listPolres,
                onChanged: _onPolresChanged,
                icon: Icons.local_police,
              ),
              const SizedBox(height: 16),

              // 2. KEPOLISIAN SEKTOR (POLSEK)
              _buildDropdown(
                label: "Kepolisian Sektor",
                hint:
                    _selectedPolres == null
                        ? "Pilih Polres Terlebih Dahulu"
                        : "Pilih Polsek",
                value: _selectedPolsek,
                items: _listPolsek,
                onChanged:
                    _selectedPolres == null
                        ? null
                        : _onPolsekChanged, // Disable jika Polres belum dipilih
                icon: Icons.shield,
              ),
              const SizedBox(height: 16),

              // 3. JENIS LAHAN
              _buildDropdown(
                label: "Jenis Lahan",
                hint: "Pilih Jenis Lahan",
                value: _selectedJenisLahan,
                items: _listJenisLahan,
                onChanged: (val) => setState(() => _selectedJenisLahan = val),
                icon: Icons.landscape,
              ),
              const SizedBox(height: 16),

              // 4. KOMODITI LAHAN
              _buildDropdown(
                label: "Komoditi Lahan",
                hint: "Pilih Komoditas",
                value: _selectedKomoditas,
                items: _listKomoditas,
                onChanged: (val) => setState(() => _selectedKomoditas = val),
                icon: Icons.grass,
              ),

              const SizedBox(height: 32),

              // ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onReset();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Kirim Data Map Filter
                        widget.onApply({
                          'polres': _selectedPolres ?? '',
                          'polsek': _selectedPolsek ?? '',
                          'jenis_lahan': _selectedJenisLahan ?? '',
                          'komoditas': _selectedKomoditas ?? '',
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0097B2), // Cyan
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Terapkan Filter",
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color:
                onChanged == null ? Colors.grey.shade100 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Row(
                children: [
                  Icon(icon, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    hint,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
