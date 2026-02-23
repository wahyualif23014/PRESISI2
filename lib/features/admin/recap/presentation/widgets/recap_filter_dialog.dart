import 'package:flutter/material.dart';

class RecapFilterDialog extends StatefulWidget {
  final bool initPolres;
  final bool initPolsek;
  final bool initDesa;

  const RecapFilterDialog({
    Key? key,
    this.initPolres = true,
    this.initPolsek = true,
    this.initDesa = true,
  }) : super(key: key);

  @override
  State<RecapFilterDialog> createState() => _RecapFilterDialogState();
}

class _RecapFilterDialogState extends State<RecapFilterDialog> {
  late bool _isPolres;
  late bool _isPolsek;
  late bool _isDesa;

  // Warna Utama (Ungu)
  final Color _primaryColor = const Color(0xFF673AB7);

  @override
  void initState() {
    super.initState();
    _isPolres = widget.initPolres;
    _isPolsek = widget.initPolsek;
    _isDesa = widget.initDesa;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 5,
      insetPadding: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Tinggi menyesuaikan isi
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: Judul & Reset
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filter Data",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B), // Warna teks gelap elegan
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isPolres = true;
                      _isPolsek = true;
                      _isDesa = true;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      "Reset",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Pilih tingkat wilayah yang ingin ditampilkan:",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // OPSI FILTER
            // Menggunakan fungsi helper agar kode rapi
            _buildCheckRow(
              "Level Polres",
              _isPolres,
              (v) => setState(() => _isPolres = v),
            ),
            const SizedBox(height: 12),
            _buildCheckRow(
              "Level Polsek",
              _isPolsek,
              (v) => setState(() => _isPolsek = v),
            ),
            const SizedBox(height: 12),
            _buildCheckRow(
              "Level Desa",
              _isDesa,
              (v) => setState(() => _isDesa = v),
            ),

            const SizedBox(height: 32),

            // TOMBOL AKSI (Batal & Terapkan)
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.grey.shade700,
                    ),
                    child: const Text(
                      "Batal",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'polres': _isPolres,
                        'polsek': _isPolsek,
                        'desa': _isDesa,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Terapkan",
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  // Widget Baris Checkbox Custom
  Widget _buildCheckRow(String label, bool value, Function(bool) onChanged) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // Beri background tipis jika aktif agar terlihat jelas
            color: value ? _primaryColor.withOpacity(0.05) : Colors.transparent,
          ),
          child: Row(
            children: [
              // Checkbox Custom
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: value ? _primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: value ? _primaryColor : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child:
                    value
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
              ),
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: value ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
