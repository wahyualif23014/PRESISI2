import 'package:flutter/material.dart';

// Enum untuk menentukan mode: Tambah atau Hapus
enum JabatanFormType { add, delete }

class JabatanFormWidget extends StatelessWidget {
  final JabatanFormType type;
  final TextEditingController jabatanController;
  final TextEditingController namaController;
  final TextEditingController nrpController;
  final TextEditingController tanggalController;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const JabatanFormWidget({
    super.key,
    required this.type,
    required this.jabatanController,
    required this.namaController,
    required this.nrpController,
    required this.tanggalController,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Logika Penentuan Teks & Icon berdasarkan Tipe
    final isAdd = type == JabatanFormType.add;
    
    final title = isAdd ? "Tambah Data Jabatan" : "Hapus Data Jabatan";
    final submitLabel = isAdd ? "Tambah Personel" : "Hapus Personel";
    
    final submitIcon = isAdd ? Icons.add : Icons.delete_outline;


    final submitColor = const Color(0xFF00C853); 

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Tinggi menyesuaikan konten
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- HEADER ---
          Column(
            children: [
              // Icon Polisi (Menggunakan icon standar flutter yang mirip)
              const Icon(
                Icons.local_police_outlined,
                size: 64,
                color: Colors.black,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- FORM FIELDS ---
          _buildLabelAndInput("Nama Jabatan", jabatanController),
          _buildLabelAndInput("Nama Lengkap", namaController),
          _buildLabelAndInput("NRP Personel", nrpController),
          // Tanggal biasanya readOnly agar user memilih lewat DatePicker
          // Tapi disini disamakan stylenya dengan input text biasa
          _buildLabelAndInput("Tanggal Peresmian Jabatan", tanggalController),

          const SizedBox(height: 32),

          // --- ACTION BUTTONS ---
          Row(
            children: [
              // Tombol Cancel (Merah)
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000), // Merah terang
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.close, size: 24),
                    label: const Text(
                      "Cancel Personel",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 14
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Tombol Submit (Hijau) - Dinamis (Tambah/Hapus)
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: submitColor, // Hijau sesuai gambar
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(submitIcon, size: 24),
                    label: Text(
                      submitLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 14
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Jarak aman untuk keyboard di Android/iOS
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  // Widget Helper untuk membuat Label + Input Field yang seragam
  Widget _buildLabelAndInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold, // Label tebal hitam
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE0E0E0), // Abu-abu muda seperti di gambar
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none, // Tidak ada garis border
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, 
                vertical: 16
              ),
            ),
          ),
        ],
      ),
    );
  }
}