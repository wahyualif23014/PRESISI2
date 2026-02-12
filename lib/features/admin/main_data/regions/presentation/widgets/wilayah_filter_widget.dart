import 'package:flutter/material.dart';

class WilayahFilterWidget extends StatefulWidget {
  final List<String> availableKabupaten; // Data dinamis dari provider
  final Function(List<String>) onApply;
  final VoidCallback onReset;

  const WilayahFilterWidget({
    super.key,
    required this.availableKabupaten,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<WilayahFilterWidget> createState() => _WilayahFilterWidgetState();
}

class _WilayahFilterWidgetState extends State<WilayahFilterWidget> {
  // Simpan kabupaten yang dipilih
  final Set<String> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    // Warna tema
    const Color goldColor = Color(0xFFC0A100);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filter Wilayah",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${_selectedItems.length} Dipilih",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(height: 24),

            const Text(
              "Pilih Kabupaten:",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),

            // List Checkbox Dinamis
            SizedBox(
              height: 200, // Batasi tinggi agar scrollable
              child:
                  widget.availableKabupaten.isEmpty
                      ? const Center(child: Text("Tidak ada opsi filter"))
                      : RawScrollbar(
                        thumbColor: Colors.grey.shade300,
                        radius: const Radius.circular(4),
                        thickness: 4,
                        child: ListView.separated(
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 4),
                          itemCount: widget.availableKabupaten.length,
                          itemBuilder: (context, index) {
                            final kab = widget.availableKabupaten[index];
                            final isSelected = _selectedItems.contains(kab);

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedItems.remove(kab);
                                  } else {
                                    _selectedItems.add(kab);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? goldColor.withOpacity(0.1)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? goldColor
                                            : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color:
                                          isSelected
                                              ? goldColor
                                              : Colors.grey.shade400,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        kab,
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? Colors.black87
                                                  : Colors.grey.shade600,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            ),

            const SizedBox(height: 24),

            // Buttons Action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _selectedItems.clear());
                      widget.onReset();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black54,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Reset"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onApply(_selectedItems.toList()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
}
