import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/data/model/land_potential_model.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/land_detail_dialog.dart';

class LandPotentialCard extends StatelessWidget {
  final LandPotentialModel data;

  const LandPotentialCard({super.key, required this.data});

  // GANTI IP INI SESUAI SERVER KAMU (Pastikan folder 'uploads' bisa diakses)
  // Jika backend kamu menyimpan full URL, variabel ini tidak dipakai.
  final String _imageBaseUrl = "http://192.168.1.8:8080/uploads/"; 

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Sedikit jarak antar card
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Sudut melengkung biar modern
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => LandDetailDialog(data: data),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // KOLOM 1: FOTO LAHAN (DARI DATABASE)
                // ==========================================
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: _buildLandImage(),
                  ),
                ),

                const SizedBox(width: 12),

                // ==========================================
                // KOLOM 2: INFO PERSONEL & MAPS LOKASI
                // ==========================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A. INFO PERSONEL (Polisi & PIC)
                      Row(
                        children: [
                          const Icon(Icons.local_police_rounded, size: 14, color: Color(0xFF0097B2)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              data.policeName.isNotEmpty ? data.policeName : "Polisi: -",
                              style: const TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold,
                                color: Colors.black87
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              data.picName.isNotEmpty ? data.picName : "PIC: -",
                              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // B. MAPS / LOKASI (GAYA PETA)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD), // Biru muda ala Maps
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                data.alamatLahan,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF1565C0), // Biru teks link
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // ==========================================
                // KOLOM 3: STATUS & ACTION BUTTONS
                // ==========================================
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 1. Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: data.statusValidasi == 'TERVALIDASI' 
                            ? const Color(0xFFE8F5E9) 
                            : const Color(0xFFFFF3E0), 
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: data.statusValidasi == 'TERVALIDASI' 
                            ? Colors.green 
                            : Colors.orange,
                          width: 1
                        )
                      ),
                      child: Text(
                        data.statusValidasi == 'TERVALIDASI' ? 'Valid' : 'Belum',
                        style: TextStyle(
                          color: data.statusValidasi == 'TERVALIDASI' 
                            ? Colors.green[700] 
                            : Colors.orange[800],
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // 2. Tombol Aksi (Kecil Vertikal)
                    Row(
                      children: [
                        _buildSmallActionButton(Icons.edit, Colors.blue, () {}),
                        const SizedBox(width: 4),
                        _buildSmallActionButton(Icons.delete, Colors.red, () {}),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER: MENAMPILKAN GAMBAR ---
  Widget _buildLandImage() {
    if (data.fotoLahan.isEmpty || data.fotoLahan == "-") {
      return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 30));
    }

    // Cek apakah URL lengkap atau cuma nama file
    String imageUrl = data.fotoLahan;
    if (!imageUrl.startsWith("http")) {
      imageUrl = "$_imageBaseUrl$imageUrl";
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
      },
    );
  }

  // --- HELPER: TOMBOL KECIL ---
  Widget _buildSmallActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}