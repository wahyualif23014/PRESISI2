import 'package:flutter/material.dart';

class UnitFilterDialog extends StatefulWidget {
  // Update Callback: Tambah parameter 'wilayah'
  final Function(bool isPolres, bool isPolsek, String wilayah, String query)
  onApply;
  final VoidCallback onReset;

  // Data Awal
  final bool initialPolres;
  final bool initialPolsek;
  final String initialWilayah;
  final List<String> availableWilayahs; // List wilayah dari Provider

  const UnitFilterDialog({
    super.key,
    required this.onApply,
    required this.onReset,
    this.initialPolres = true,
    this.initialPolsek = true,
    this.initialWilayah = "Semua",
    required this.availableWilayahs,
  });

  @override
  State<UnitFilterDialog> createState() => _UnitFilterDialogState();
}

class _UnitFilterDialogState extends State<UnitFilterDialog> {
  late bool _isPolresChecked;
  late bool _isPolsekChecked;
  late String _selectedWilayah;
  final TextEditingController _localSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isPolresChecked = widget.initialPolres;
    _isPolsekChecked = widget.initialPolsek;
    _selectedWilayah = widget.initialWilayah;

    // Pastikan nilai awal ada di dalam list (safety check)
    if (!widget.availableWilayahs.contains(_selectedWilayah)) {
      _selectedWilayah = "Semua";
    }
  }

  @override
  void dispose() {
    _localSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Text(
              "Filter Lanjutan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E40AF),
              ),
            ),
            const SizedBox(height: 16),

            // 1. FILTER WILAYAH (DROPDOWN)
            const Text(
              "Pilih Wilayah",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedWilayah,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF1E40AF),
                  ),
                  items:
                      widget.availableWilayahs.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() => _selectedWilayah = newValue);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. FILTER TIPE (CHECKBOX)
            const Text(
              "Tampilkan Tipe",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            _buildCheckboxTile("Polres (Induk)", _isPolresChecked, (val) {
              setState(() => _isPolresChecked = val!);
            }),
            _buildCheckboxTile("Polsek (Anak)", _isPolsekChecked, (val) {
              setState(() => _isPolsekChecked = val!);
            }),
            const SizedBox(height: 16),

            // 3. SEARCH TEXT (Optional)
            TextField(
              controller: _localSearchController,
              decoration: InputDecoration(
                hintText: "Cari nama kesatuan...",
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.grey,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // TOMBOL AKSI
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(
                        _isPolresChecked,
                        _isPolsekChecked,
                        _selectedWilayah,
                        _localSearchController.text,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Terapkan"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isPolresChecked = true;
                        _isPolsekChecked = true;
                        _selectedWilayah = "Semua";
                        _localSearchController.clear();
                      });
                      widget.onReset();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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

  Widget _buildCheckboxTile(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: const Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
