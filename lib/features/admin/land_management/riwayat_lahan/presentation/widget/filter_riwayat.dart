import 'package:flutter/material.dart';

class FilterriwayatDialog extends StatefulWidget {
  final Function(String keyword, List<String> selectedFilters) onApply;
  final VoidCallback onReset;

  const FilterriwayatDialog({
    super.key,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterriwayatDialog> createState() => _FilterriwayatDialog();
}

class _FilterriwayatDialog extends State<FilterriwayatDialog> {
  final TextEditingController _searchController = TextEditingController();

  // Data dummy untuk opsi filter (sesuai gambar)
  final List<String> _filterOptions = [
    'Kabupaten',
    'Kecamatan',
    'Desa',
    'Dusun',
  ];
  final List<String> _selectedFilters = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFilter(String option, bool? value) {
    setState(() {
      if (value == true) {
        _selectedFilters.add(option);
      } else {
        _selectedFilters.remove(option);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Penting agar dialog tidak full screen
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter Data Lahan",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Search Input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari Data",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Checkbox List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filterOptions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final option = _filterOptions[index];
                  final isSelected = _selectedFilters.contains(option);

                  return GestureDetector(
                    onTap: () => _toggleFilter(option, !isSelected),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: isSelected,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(color: Colors.grey),
                            onChanged: (val) => _toggleFilter(option, val),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          option,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_searchController.text, _selectedFilters);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF1B9D5E,
                      ), // Warna Hijau sesuai gambar
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Apply"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onReset();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black87),
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
}
