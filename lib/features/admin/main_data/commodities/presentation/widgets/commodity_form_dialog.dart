import 'package:flutter/material.dart';

class CommodityFormDialog extends StatefulWidget {
  final bool isEdit;
  final String? initialName;
  final String? initialDescription;
  final VoidCallback onCancel;
  final Function(String name, String desc) onConfirm;

  const CommodityFormDialog({
    super.key,
    this.isEdit = false, // Default adalah Tambah
    this.initialName,
    this.initialDescription,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<CommodityFormDialog> createState() => _CommodityFormDialogState();
}

class _CommodityFormDialogState extends State<CommodityFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descController = TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menentukan teks dan warna berdasarkan mode Edit/Tambah
    final String title = widget.isEdit ? "Edit komoditi" : "Tambah komoditi";
    final String btnLabel = widget.isEdit ? "Edit" : "Tambah";
    final IconData headerIcon = Icons.forest; // Ikon pohon

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Icon + Title)
              Row(
                children: [
                  Icon(headerIcon, size: 32, color: Colors.black),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Input Nama
              _buildLabel("Nama Komoditi Lahan"),
              _buildTextField(
                controller: _nameController,
                hint: "",
                height: 50,
              ),
              const SizedBox(height: 16),

              // 3. Input Deskripsi
              _buildLabel("Tambahkan Deskripsi Komoditi Lahan"),
              _buildTextField(
                controller: _descController,
                hint: "",
                height: 100,
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // 4. Upload Foto Area
              _buildLabel("Foto Komoditi lahan"),
              GestureDetector(
                onTap: () {
                  // TODO: Implementasi Image Picker disini
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Fitur Upload Gambar")),
                  );
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate, size: 40, color: Colors.black),
                      SizedBox(height: 8),
                      Text(
                        "Upload Gambar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Action Buttons
              Row(
                children: [
                  // Tombol Cancel (Merah)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text("Cancel"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0000), // Merah
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Action (Hijau)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onConfirm(_nameController.text, _descController.text);
                      },
                      icon: Icon(
                        widget.isEdit ? Icons.edit_note : Icons.add,
                        color: Colors.white,
                      ),
                      label: Text(btnLabel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853), // Hijau
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required double height,
    int maxLines = 1,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0), // Warna abu-abu input
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}