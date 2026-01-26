import 'package:flutter/material.dart';

class UnitFilterDialog extends StatefulWidget {
  final VoidCallback onApply;
  final VoidCallback onReset;

  const UnitFilterDialog({
    super.key,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<UnitFilterDialog> createState() => _UnitFilterDialogState();
}

class _UnitFilterDialogState extends State<UnitFilterDialog> {
  // State untuk Checkbox
  bool _isPolresChecked = false;
  bool _isPolsekChecked = false;
  
  // Controller untuk search di dalam filter
  final TextEditingController _localSearchController = TextEditingController();

  @override
  void dispose() {
    _localSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Radius sudut dialog
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white, // Memastikan background tetap putih
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 320, // Lebar fixed agar proporsional
        child: Column(
          mainAxisSize: MainAxisSize.min, // Tinggi menyesuaikan konten
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. JUDUL
            const Text(
              "Filter Data Polres Dan Polsek",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // 2. SEARCH BAR (Di dalam Popup)
            TextField(
              controller: _localSearchController,
              decoration: InputDecoration(
                hintText: "Cari Data",
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. LIST CHECKBOX DENGAN SCROLLBAR
            SizedBox(
              height: 120, // Batasi tinggi area list agar bisa di-scroll jika item banyak
              child: Scrollbar(
                thumbVisibility: true, // Tampilkan batang scroll
                thickness: 4,
                radius: const Radius.circular(10),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildCheckboxTile("Polres", _isPolresChecked, (val) {
                      setState(() => _isPolresChecked = val!);
                    }),
                    _buildCheckboxTile("Polsek", _isPolsekChecked, (val) {
                      setState(() => _isPolsekChecked = val!);
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. TOMBOL AKSI (Apply & Reset)
            Row(
              children: [
                // Tombol Apply (Hijau)
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply();
                        Navigator.pop(context); // Tutup dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20), // Hijau Tua sesuai gambar
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Apply",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Tombol Reset (Teks Abu)
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isPolresChecked = false;
                        _isPolsekChecked = false;
                        _localSearchController.clear();
                      });
                      widget.onReset();
                    },
                    child: const Text(
                      "Reset",
                      style: TextStyle(
                        color: Colors.grey, 
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk membuat baris Checkbox
  Widget _buildCheckboxTile(String label, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: BorderSide(color: Colors.grey.shade500, width: 1.5),
              activeColor: const Color(0xFF1B5E20), // Hijau saat dicentang
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}