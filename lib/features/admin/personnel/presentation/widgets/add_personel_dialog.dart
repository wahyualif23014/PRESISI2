import 'package:flutter/material.dart';

class AddPersonelDialog extends StatefulWidget {
  const AddPersonelDialog({super.key});

  @override
  State<AddPersonelDialog> createState() => _AddPersonelDialogState();
}

class _AddPersonelDialogState extends State<AddPersonelDialog> {
  // Controller untuk input text
  final _namaController = TextEditingController();
  final _nrpController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _peranController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _nrpController.dispose();
    _phoneController.dispose();
    _jabatanController.dispose();
    _peranController.dispose();
    super.dispose();
  }

  // --- LOGIKA DUMMY (HANYA VISUAL) ---
  void _submitVisualOnly() {
    // 1. Validasi Tampilan Saja
    if (_namaController.text.isEmpty || _nrpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama dan NRP wajib diisi (Simulasi Validasi)"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Print ke Console untuk cek input (Opsional)
    print("Simulasi Tambah Data:");
    print("Nama: ${_namaController.text}");
    print("NRP: ${_nrpController.text}");
    print("Jabatan: ${_jabatanController.text}");

    // 3. Tutup Dialog
    Navigator.of(context).pop();

    // 4. Feedback Sukses (Visual Saja)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tampilan OK: Tombol Add ditekan"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20), // Memberi jarak dari tepi layar
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- HEADER ---
              Center(
                child: Column(
                  children: [
                    // Icon
                    const Icon(Icons.local_police_outlined, size: 48, color: Colors.black),
                    const SizedBox(height: 12),
                    // Judul
                    const Text(
                      "Tambah Data Personel",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- FORM FIELDS ---
              _buildLabelAndInput("Nama Personel", _namaController),
              _buildLabelAndInput("NRP Personel", _nrpController, isNumber: true),
              _buildLabelAndInput("NO Telepon Personel", _phoneController, isNumber: true),
              _buildLabelAndInput("Jabatan Personel", _jabatanController),
              _buildLabelAndInput("Peran Personel", _peranController),

              const SizedBox(height: 24),

              // --- BUTTONS ---
              Row(
                children: [
                  // Tombol Cancel (Merah)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0000), // Merah terang
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Tombol Add (Hijau)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitVisualOnly,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853), // Hijau sesuai desain
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        "Add",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelAndInput(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE0E0E0), // Abu-abu muda (Grey 300 equivalent)
              hintText: "Masukkan $label...", // Placeholder text
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none, // Hilangkan garis border
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}