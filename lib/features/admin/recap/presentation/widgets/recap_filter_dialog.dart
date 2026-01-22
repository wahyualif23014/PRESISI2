import 'package:flutter/material.dart';

class RecapFilterDialog extends StatefulWidget {
  const RecapFilterDialog({Key? key}) : super(key: key);

  @override
  State<RecapFilterDialog> createState() => _RecapFilterDialogState();
}

class _RecapFilterDialogState extends State<RecapFilterDialog> {
  // State untuk Checkbox
  bool _isPolres = false;
  bool _isPolsek = false;
  bool _isDesa = false;

  // Warna sesuai desain (Hijau)
  final Color _primaryGreen = const Color(0xFF1B9E5E);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar tinggi dialog menyesuaikan konten
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1. HEADER TABS (Wilayah vs Tahun)
            Row(
              children: [
                _buildTabButton("Wilayah", isActive: true),
                const SizedBox(width: 12),
                _buildTabButton("Tahun", isActive: false),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 2. LABEL & SEARCH BAR
            const Text(
              "Filter Data Lahan",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "Cari Data",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 0.5),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. CHECKBOX LIST
            // Menggunakan Column biasa karena itemnya sedikit
            Column(
              children: [
                _buildCheckboxItem("Polres", _isPolres, (val) => setState(() => _isPolres = val!)),
                _buildCheckboxItem("Polsek", _isPolsek, (val) => setState(() => _isPolsek = val!)),
                _buildCheckboxItem("Desa", _isDesa, (val) => setState(() => _isDesa = val!)),
              ],
            ),

            const SizedBox(height: 24),

            // 4. ACTION BUTTONS (Apply & Reset)
            Row(
              children: [
                // Tombol Apply (Hijau)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Tutup dialog dan kirim data balik (opsional)
                      Navigator.pop(context, {
                        'polres': _isPolres,
                        'polsek': _isPolsek,
                        'desa': _isDesa,
                      });
                    },
                    child: const Text("Apply", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Reset (Putih/Outline)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPolres = false;
                        _isPolsek = false;
                        _isDesa = false;
                      });
                    },
                    child: const Text("Reset", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER: Tab Atas (Wilayah/Tahun) ---
  Widget _buildTabButton(String label, {required bool isActive}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? _primaryGreen : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(6),
          border: isActive ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isActive ? Colors.white : Colors.black54,
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER: Item Checkbox Custom ---
  Widget _buildCheckboxItem(String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              activeColor: _primaryGreen,
              side: BorderSide(color: Colors.grey.shade400, width: 1.5),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}