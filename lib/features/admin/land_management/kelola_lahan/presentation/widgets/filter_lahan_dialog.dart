import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
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

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final result = await _repo.getFilterOptions();

      // PERBAIKAN: Casting Map untuk mengambil key 'data' dari Backend
      final Map<String, dynamic> response = result as Map<String, dynamic>;
      final Map<String, dynamic> data = response['data'] ?? response;

      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final bool isAdmin = auth.user?.role?.toString().contains('admin') ?? false;
      final unitName = auth.user?.tingkatDetail?.nama ?? '';
      final isPolres = unitName.toUpperCase().contains('POLRES');

      setState(() {
        _listPolres = List<String>.from(data['polres'] ?? []);
        _listJenisLahan = List<String>.from(data['jenis_lahan'] ?? []);
        _listKomoditas = List<String>.from(data['komoditas'] ?? []);
      });

      final unitNameUpper = unitName.toUpperCase();
      final bool isPolresUnit = !isAdmin && unitNameUpper.contains('POLRES');
      final bool isPolsekUnit = !isAdmin && unitNameUpper.contains('POLSEK');

      if (isPolresUnit) {
        // Admin/Operator Polres: set Polres, load Polseks
        final polresMatch = _listPolres.where((p) => p == unitName).toList();
        if (polresMatch.isNotEmpty) {
          _selectedPolres = polresMatch.first;
          _onPolresChanged(_selectedPolres);
        } else {
          _selectedPolres = unitName;
          _listPolres.add(unitName);
          _onPolresChanged(_selectedPolres);
        }
      } else if (isPolsekUnit) {
        // Operator Polsek: lock both Polres and Polsek
        _selectedPolres = "Polres (Otomatis)";
        if (!_listPolres.contains(_selectedPolres)) {
          _listPolres.insert(0, _selectedPolres!);
        }
        
        _selectedPolsek = unitName;
        if (!_listPolsek.contains(_selectedPolsek)) {
          _listPolsek.insert(0, _selectedPolsek!);
        }
        
        try {
           final result = await _repo.getFilterOptions(polsek: _selectedPolsek);
           final Map<String, dynamic> response = result as Map<String, dynamic>;
           final Map<String, dynamic> data = response['data'] ?? response;
           if (mounted) {
             setState(() {
               _listJenisLahan = List<String>.from(data['jenis_lahan'] ?? _listJenisLahan);
               _listKomoditas = List<String>.from(data['komoditas'] ?? _listKomoditas);
             });
           }
        } catch(e) {}
      }
    } catch (e) {
      debugPrint("Error Load Initial: $e");
    } finally {
      // Pastikan loading berhenti agar dropdown bisa diklik
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Load cascading: Saat Polres dipilih, muat Polsek spesifik
  Future<void> _onPolresChanged(String? val) async {
    setState(() {
      _selectedPolres = val;
      _selectedPolsek = null;
      _listPolsek = [];
      _isLoading = true;
    });

    if (val != null) {
      try {
        final result = await _repo.getFilterOptions(polres: val);
        final Map<String, dynamic> response = result as Map<String, dynamic>;
        final Map<String, dynamic> data = response['data'] ?? response;

        if (mounted) {
          setState(() {
            _listPolsek = List<String>.from(data['polsek'] ?? []);
            _listJenisLahan = List<String>.from(
              data['jenis_lahan'] ?? _listJenisLahan,
            );
            _listKomoditas = List<String>.from(
              data['komoditas'] ?? _listKomoditas,
            );
          });
        }
      } catch (e) {
        debugPrint("Error Load Polsek: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      _loadInitialData();
    }
  }

  // Load cascading: Saat Polsek dipilih
  Future<void> _onPolsekChanged(String? val) async {
    setState(() {
      _selectedPolsek = val;
      _isLoading = true;
    });

    if (val != null) {
      try {
        final result = await _repo.getFilterOptions(
          polres: _selectedPolres,
          polsek: val,
        );
        final Map<String, dynamic> response = result as Map<String, dynamic>;
        final Map<String, dynamic> data = response['data'] ?? response;

        if (mounted) {
          setState(() {
            _listJenisLahan = List<String>.from(
              data['jenis_lahan'] ?? _listJenisLahan,
            );
            _listKomoditas = List<String>.from(
              data['komoditas'] ?? _listKomoditas,
            );
          });
        }
      } catch (e) {
        debugPrint("Error Load Data Polsek: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final bool isAdmin = auth.user?.role?.toString().contains('admin') ?? false;
    final unitName = auth.user?.tingkatDetail?.nama ?? '';
    final unitNameUpper = unitName.toUpperCase();
    final bool isLockedToPolres = !isAdmin && (unitNameUpper.contains('POLRES') || unitNameUpper.contains('POLSEK'));
    final bool isLockedToPolsek = !isAdmin && unitNameUpper.contains('POLSEK');

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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0097B2),
                      ),
                    ),
                ],
              ),
              const Divider(height: 30),

              // 1. KEPOLISIAN RESOR (POLRES)
              _buildDropdown(
                label: "Kepolisian Resor",
                hint:
                    _listPolres.isEmpty && _isLoading
                        ? "Memuat..."
                        : "Pilih Polres",
                value: _selectedPolres,
                items: _listPolres.toSet().toList(),
                onChanged: (_isLoading || isLockedToPolres) ? null : _onPolresChanged,
                icon: Icons.local_police,
              ),
              const SizedBox(height: 16),

              // 2. KEPOLISIAN SEKTOR (POLSEK)
              _buildDropdown(
                label: "Kepolisian Sektor",
                hint:
                    _selectedPolres == null && !isLockedToPolres
                        ? "Pilih Polres Terlebih Dahulu"
                        : "Pilih Polsek",
                value: _selectedPolsek,
                items: _listPolsek.toSet().toList(),
                onChanged:
                    (_selectedPolres == null && !isLockedToPolres) || _isLoading || isLockedToPolsek
                        ? null
                        : _onPolsekChanged,
                icon: Icons.shield,
              ),
              const SizedBox(height: 16),

              // 3. JENIS LAHAN
              _buildDropdown(
                label: "Jenis Lahan",
                hint: "Pilih Jenis Lahan",
                value: _selectedJenisLahan,
                items: _listJenisLahan.toSet().toList(),
                onChanged:
                    _isLoading
                        ? null
                        : (val) => setState(() => _selectedJenisLahan = val),
                icon: Icons.landscape,
              ),
              const SizedBox(height: 16),

              // 4. KOMODITI LAHAN
              _buildDropdown(
                label: "Komoditi Lahan",
                hint: "Pilih Komoditas",
                value: _selectedKomoditas,
                items: _listKomoditas.toSet().toList(),
                onChanged:
                    _isLoading
                        ? null
                        : (val) => setState(() => _selectedKomoditas = val),
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
                        Map<String, String> filters = {};
                        if (isLockedToPolsek) {
                          filters['polres'] = _selectedPolres ?? '';
                          filters['polsek'] = auth.user?.tingkatDetail?.nama ?? '';
                        } else if (isLockedToPolres) {
                          filters['polres'] = auth.user?.tingkatDetail?.nama ?? '';
                          filters['polsek'] = _selectedPolsek ?? '';
                        } else {
                          filters['polres'] = _selectedPolres ?? '';
                          filters['polsek'] = _selectedPolsek ?? '';
                        }
                        filters['jenis_lahan'] = _selectedJenisLahan ?? '';
                        filters['komoditas'] = _selectedKomoditas ?? '';

                        widget.onApply(filters);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0097B2),
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
    final bool isActuallyEnabled = items.isNotEmpty && onChanged != null;

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
                isActuallyEnabled ? Colors.grey.shade50 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              hint: Row(
                children: [
                  Icon(icon, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _isLoading && items.isEmpty ? "Mengambil data..." : hint,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
              isExpanded: true,
              icon:
                  _isLoading && items.isEmpty
                      ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 13)),
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
