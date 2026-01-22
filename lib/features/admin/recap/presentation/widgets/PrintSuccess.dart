import 'package:flutter/material.dart';

class PrintSuccessWidget extends StatelessWidget {
  final String fileName;
  final VoidCallback onPrintTap;

  const PrintSuccessWidget({
    Key? key,
    required this.fileName,
    required this.onPrintTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onPrintTap, // Fungsi _handlePrint dipanggil di sini
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            // Opsional: berikan shadow tipis jika ingin terlihat seperti card
            // boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Agar tinggi menyesuaikan konten
            children: [
              // 1. IKON PDF DENGAN BADGE CENTANG
              SizedBox(
                height: 80,
                width: 80,
                child: Stack(
                  children: [
                    // Ikon PDF (Base)
                    const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.picture_as_pdf_outlined, // Atau Icons.description_outlined
                        size: 70,
                        color: Color(0xFF2F80ED), // Warna Biru PDF
                      ),
                    ),
                    // Badge Centang Hijau (Overlay)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00C853), // Warna Hijau
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              spreadRadius: 2, // Border putih di sekeliling centang
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. NAMA FILE
              Text(
                fileName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // 3. STATUS "FILE BERHASIL TERUNDUH"
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ikon verified kecil (seperti di gambar: hijau bergerigi)
                  const Icon(
                    Icons.verified, 
                    color: Color(0xFF00C853), // Hijau
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "File Berhasil Terunduh",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2F80ED), // Biru Text
                      fontWeight: FontWeight.w600,
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
}