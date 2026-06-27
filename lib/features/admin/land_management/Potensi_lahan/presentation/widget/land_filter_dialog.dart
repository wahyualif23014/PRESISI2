import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
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

  List<Map<String, dynamic>> _listPolres = [];
  List<Map<String, dynamic>> _listPolsek = [];

  final List<String> _listJenis = [
    "PRODUKTIF (POKTAN BINAAN POLRI)",
    "HUTAN (PERHUTANAN SOSIAL)",
    "LUAS BAKU SAWAH (LBS)",
    "PESANTREN",
    "MILIK POLRI",
    "PRODUKTIF (MASYARAKAT BINAAN POLRI)",
    "PRODUKTIF (TUMPANG SARI)",
    "HUTAN (PERHUTANI/INHUTANI)",
    "LAHAN LAINNYA",
  ];

  final List<String> _listValidasi = ["Sudah Divalidasi", "Belum Divalidasi"];

  String? _selPolres, _selPolsek, _selJenis, _selValidasi;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final data = await _service.fetchDynamicWilayah();
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final bool isAdmin = auth.user?.role?.toString().contains('admin') ?? false;
    final unitName = auth.user?.tingkatDetail?.nama ?? '';
    final unitNameUpper = unitName.toUpperCase();
    final bool isPolresUnit = !isAdmin && unitNameUpper.contains('POLRES');
    final bool isPolsekUnit = !isAdmin && unitNameUpper.contains('POLSEK');

    setState(() {
      _listPolres = data;
      _isLoading = false;
    });

    if (isPolresUnit) {
      _selPolres = unitName;
      _loadPolsek(unitName);
    } else if (isPolsekUnit) {
      _selPolres = "Polres (Otomatis)";
      if (!_listPolres.any((e) => e['nama'] == _selPolres)) {
         _listPolres.insert(0, {'kode': 'DUMMY_POLRES', 'nama': _selPolres});
      }
      _selPolsek = unitName;
      if (!_listPolsek.any((e) => e['nama'] == _selPolsek)) {
         _listPolsek.insert(0, {'kode': 'DUMMY_POLSEK', 'nama': _selPolsek});
      }
    }
  }

  Future<void> _loadPolsek(String? polresName) async {
    if (polresName == null) return;

    setState(() {
      _isLoading = true;
      _selPolsek = null;
    });

    final data = await _service.fetchDynamicWilayah(polres: polresName);

    setState(() {
      _listPolsek = data;
      _isLoading = false;
    });
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
              _listPolres.isEmpty
                  ? _buildEmptyState("Data Polres tidak ada")
                  : _buildDropWilayah(
                    label: "Kepolisian Resor",
                    icon: Icons.account_balance,
                    items: _listPolres,
                    value: _selPolres,
                    onChanged: isLockedToPolres ? null : (v) {
                      if (v == null) return;
                      setState(() {
                        _selPolres = v;
                        _selPolsek = null;
                        _isLoading = true;
                      });
                      _loadPolsek(v);
                    },
                  ),
              const SizedBox(height: 16),

              _selPolres != null && _listPolsek.isEmpty && !isLockedToPolres
                  ? _buildEmptyState("Data Polsek tidak ada")
                  : _buildDropWilayah(
                    label: "Kepolisian Sektor",
                    icon: Icons.shield,
                    items: _listPolsek,
                    value: _selPolsek,
                    onChanged: isLockedToPolsek ? null : (v) {
                      if (v == null) return;
                      setState(() => _selPolsek = v);
                    },
                  ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),

              _buildDropSimple(
                label: "Jenis Lahan",
                icon: Icons.landscape,
                items: _listJenis,
                value: _selJenis,
                onChanged: (v) => setState(() => _selJenis = v),
              ),
              const SizedBox(height: 16),

              _buildDropSimple(
                label: "Status Validasi",
                icon: Icons.verified_user_outlined,
                items: _listValidasi,
                value: _selValidasi,
                onChanged: (v) => setState(() => _selValidasi = v),
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
                      Map<String, String> filters = {};
                      if (isLockedToPolsek) {
                        filters['polres'] = _selPolres ?? '';
                        filters['polsek'] = auth.user?.tingkatDetail?.nama ?? '';
                      } else if (isLockedToPolres) {
                        filters['polres'] = auth.user?.tingkatDetail?.nama ?? '';
                        if (_selPolsek != null) filters['polsek'] = _selPolsek!;
                      } else {
                        if (_selPolres != null) filters['polres'] = _selPolres!;
                        if (_selPolsek != null) filters['polsek'] = _selPolsek!;
                      }
                      filters['jenis_lahan'] = _selJenis ?? '';
                      filters['status_validasi'] = _selValidasi ?? '';
                      
                      widget.onApply(filters);
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
        color: const Color(0xFF0097B2).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF0097B2).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text("👮‍♂️", style: TextStyle(fontSize: 40)),
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

  Widget _buildDropWilayah({
    required String label,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required String? value,
    required Function(String?)? onChanged,
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
          value: items.any((e) => e['nama'] == value) ? value : null,
          isExpanded: true,
          hint: Text(
            "Pilih ${label.split(' ').last}",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
          items:
              items.map((e) {
                return DropdownMenuItem<String>(
                  value: e['nama'].toString(),
                  child: Text(
                    e['nama'].toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
          onChanged: enabled ? onChanged : null,
          decoration: _inputDecoration(icon, enabled),
        ),
      ],
    );
  }

  Widget _buildDropSimple({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          hint: Text(
            "Pilih ${label.split(' ').last}",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
          items:
              items.map((e) {
                return DropdownMenuItem<String>(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
          onChanged: onChanged,
          decoration: _inputDecoration(icon, true),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(IconData icon, bool enabled) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        size: 20,
        color: enabled ? const Color(0xFF0097B2) : Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        borderSide: const BorderSide(color: Color(0xFF0097B2), width: 1.5),
      ),
    );
  }
}
