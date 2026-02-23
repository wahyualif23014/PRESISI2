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

  // Data List Dropdown (Akan diambil dari API/Database)
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

  // 1. Load data awal (Daftar Polres)
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repo.getFilterOptions();
      if (mounted) {
        setState(() {
          _listPolres = data['polres'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading initial filter data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Saat Polres berubah -> Tarik data Polsek yang relevan
  Future<void> _onPolresChanged(String? val) async {
    setState(() {
      _selectedPolres = val;
      _selectedPolsek = null; // Reset pilihan dibawahnya
      _selectedJenisLahan = null;
      _selectedKomoditas = null;
      _listPolsek = [];
      _isLoading = true;
    });

    if (val != null) {
      try {
        final data = await _repo.getFilterOptions(polres: val);
        if (mounted) {
          setState(() {
            _listPolsek = data['polsek'] ?? [];
            _listJenisLahan = data['jenis_lahan'] ?? [];
            _listKomoditas = data['komoditas'] ?? [];
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error loading polsek data: $e");
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      _loadInitialData();
    }
  }

  // 3. Saat Polsek berubah -> Update filter tambahan jika ada
  Future<void> _onPolsekChanged(String? val) async {
    setState(() {
      _selectedPolsek = val;
      _isLoading = true;
    });

    if (val != null) {
      try {
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
      } catch (e) {
        debugPrint("Error updating filters: $e");
        if (mounted) setState(() => _isLoading = false);
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filter Riwayat Lahan",
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

              // 1. DROPDOWN POLRES
              _buildDropdown(
                label: "Kepolisian Resor",
                hint: "Pilih Polres",
                value: _selectedPolres,
                items: _listPolres,
                onChanged: _onPolresChanged,
                icon: Icons.local_police,
              ),
              const SizedBox(height: 16),

              // 2. DROPDOWN POLSEK
              _buildDropdown(
                label: "Kepolisian Sektor",
                hint:
                    _selectedPolres == null
                        ? "Pilih Polres Terlebih Dahulu"
                        : "Pilih Polsek",
                value: _selectedPolsek,
                items: _listPolsek,
                onChanged: _selectedPolres == null ? null : _onPolsekChanged,
                icon: Icons.shield,
              ),
              const SizedBox(height: 16),

              // 3. DROPDOWN JENIS LAHAN
              _buildDropdown(
                label: "Jenis Lahan",
                hint: "Pilih Jenis Lahan",
                value: _selectedJenisLahan,
                items: _listJenisLahan,
                onChanged: (val) => setState(() => _selectedJenisLahan = val),
                icon: Icons.landscape,
              ),
              const SizedBox(height: 16),

              // 4. DROPDOWN KOMODITI
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
                        // Mengirim data Map filter ke halaman utama
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

  // Widget Dropdown Builder (Reusable)
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
                  Expanded(
                    child: Text(
                      hint,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
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
