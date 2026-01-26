import 'package:flutter/material.dart';

class WilayahFilterWidget extends StatefulWidget {
  final VoidCallback onApply;
  final VoidCallback onReset;

  const WilayahFilterWidget({
    super.key,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<WilayahFilterWidget> createState() => _WilayahFilterWidgetState();
}

class _WilayahFilterWidgetState extends State<WilayahFilterWidget> {
  // Simulasi state checkbox
  final Map<String, bool> _filters = {
    'Kabupaten': false,
    'Kecamatan': false,
    'Desa': false,
    'Dusun': false, // Tambahan untuk demo scrollbar
    'RW': false,    // Tambahan untuk demo scrollbar
    'RT': false,    // Tambahan untuk demo scrollbar
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 300, // Lebar fixed agar proporsional seperti gambar
        child: Column(
          mainAxisSize: MainAxisSize.min, // Tinggi menyesuaikan konten
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Title
            Text(
              "Filter Data Wilayah",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Search Bar Kecil
            TextField(
              decoration: InputDecoration(
                hintText: "Cari Data",
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),

            // 3. List Checkbox dengan Scrollbar
            // Kita batasi tingginya agar scrollbar muncul seperti di gambar
            SizedBox(
              height: 150, 
              child: RawScrollbar(
                thumbColor: Colors.grey.shade300,
                radius: const Radius.circular(4),
                thickness: 6,
                thumbVisibility: true, // Agar scrollbar selalu terlihat (seperti gambar)
                child: ListView(
                  shrinkWrap: true,
                  children: _filters.keys.map((key) {
                    return Theme(
                      data: ThemeData(
                        checkboxTheme: CheckboxThemeData(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4), // Checkbox kotak rounded dikit
                          ),
                        ),
                      ),
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading, // Checkbox di kiri
                        title: Text(
                          key,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        value: _filters[key],
                        activeColor: const Color(0xFF00C853), // Hijau saat aktif
                        side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                        onChanged: (bool? value) {
                          setState(() {
                            _filters[key] = value ?? false;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 4. Buttons (Apply & Reset)
            Row(
              children: [
                // Tombol Apply (Hijau)
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853), // Warna Hijau sesuai gambar
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Apply", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Tombol Reset (Putih Border)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Logic reset visual checkbox
                      setState(() {
                        _filters.updateAll((key, value) => false);
                      });
                      widget.onReset();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black87), // Border hitam tipis
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