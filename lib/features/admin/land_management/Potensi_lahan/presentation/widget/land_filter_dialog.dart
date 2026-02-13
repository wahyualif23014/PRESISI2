import 'package:flutter/material.dart';

class LandFilterDialog extends StatefulWidget {
  const LandFilterDialog({super.key});

  @override
  State<LandFilterDialog> createState() => _LandFilterDialogState();
}

class _LandFilterDialogState extends State<LandFilterDialog> {
  // --- STATE FILTER ---
  String? _selectedStatus; // Tervalidasi / Belum
  String? _selectedPolres;
  String? _selectedPolsek;
  String? _selectedJenisLahan;

  // --- DATA DUMMY (Nanti bisa diganti API) ---
  final List<String> _listPolres = [
    "POLRES BATU",
    "POLRES BLITAR",
    "POLRES MALANG",
    "POLRES KEDIRI",
    "POLRESTA BANYUWANGI",
  ];

  final List<String> _listPolsek = [
    "POLSEK BATU",
    "POLSEK BUMIAJI",
    "POLSEK JUNREJO",
    "POLSEK LOWOKWARU",
  ];

  final List<String> _listJenisLahan = [
    "LAHAN MILIK POLRI",
    "LAHAN PRODUKTIF",
    "LAHAN TIDUR",
    "PEKARANGAN PANGAN LESTARI",
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
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
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1),

              // 1. FILTER STATUS VALIDASI (Radio Button)
              const Text("Status Validasi", style: _labelStyle),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildRadioOption("Tervalidasi", "TERVALIDASI"),
                  const SizedBox(width: 16),
                  _buildRadioOption("Belum", "BELUM TERVALIDASI"),
                ],
              ),
              const SizedBox(height: 16),

              // 2. FILTER POLRES (Dropdown)
              const Text("Kepolisian Resor", style: _labelStyle),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: "Pilih Polres",
                value: _selectedPolres,
                items: _listPolres,
                onChanged: (val) {
                  setState(() => _selectedPolres = val);
                },
              ),
              const SizedBox(height: 16),

              // 3. FILTER POLSEK (Dropdown)
              const Text("Kepolisian Sektor", style: _labelStyle),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: "Pilih Polsek",
                value: _selectedPolsek,
                items: _listPolsek,
                onChanged: (val) {
                  setState(() => _selectedPolsek = val);
                },
              ),
              const SizedBox(height: 16),

              // 4. FILTER JENIS LAHAN (Dropdown)
              const Text("Jenis Lahan", style: _labelStyle),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: "Pilih Jenis Lahan",
                value: _selectedJenisLahan,
                items: _listJenisLahan,
                onChanged: (val) {
                  setState(() => _selectedJenisLahan = val);
                },
              ),
              const SizedBox(height: 24),

              // TOMBOL TERAPKAN & RESET
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedStatus = null;
                          _selectedPolres = null;
                          _selectedPolsek = null;
                          _selectedJenisLahan = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // LOGIKA RETURN VALUE: Gabungkan semua filter jadi String Query
                        // Format sementara: "STATUS|POLRES|POLSEK|JENIS"
                        // Nanti di Page dipecah lagi.
                        // Atau kirim Map/Object. Untuk simpel, kita kirim Map.

                        Map<String, String?> filterData = {
                          'status': _selectedStatus,
                          'polres': _selectedPolres,
                          'polsek': _selectedPolsek,
                          'jenis_lahan': _selectedJenisLahan,
                        };

                        Navigator.pop(context, filterData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0097B2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
      ),
    );
  }

  // --- WIDGET HELPER ---

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black54,
  );

  Widget _buildRadioOption(String label, String value) {
    bool isSelected = _selectedStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle: Kalau diklik lagi, jadi null (uncheck)
          if (_selectedStatus == value) {
            _selectedStatus = null;
          } else {
            _selectedStatus = value;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F7FA) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0097B2) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF006064) : Colors.grey[600],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
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
    );
  }
}
