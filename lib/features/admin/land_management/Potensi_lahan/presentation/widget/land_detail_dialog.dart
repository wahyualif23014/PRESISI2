import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/model/land_potential_model.dart';

class LandDetailDialog extends StatelessWidget {
  final LandPotentialModel data;

  const LandDetailDialog({super.key, required this.data});

  Future<void> _openMaps() async {
    final String query = Uri.encodeComponent(data.alamatLahan);
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$query",
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak dapat membuka peta');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER DIALOG
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF0097B2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  "Detail Informasi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // SECTION 1: LOKASI
                  _buildSection(
                    Icons.location_on_outlined,
                    "Lokasi Lahan",
                    Colors.orange,
                    [
                      _row("Resor", data.resor),
                      _row("Sektor", data.sektor),
                      _row(
                        "Wilayah",
                        "Desa ${data.desa}, Kec. ${data.kecamatan}, Kab. ${data.kabupaten}",
                      ),
                      _row("Alamat", data.alamatLahan),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _openMaps,
                        child: const Text(
                          "LIHAT LOKASI DI GOOGLE MAPS",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // SECTION 2: PERSONEL
                  _buildSection(
                    Icons.person_outline,
                    "Personel & Pengelola",
                    Colors.blue,
                    [
                      _row(
                        "Polisi",
                        "${data.policeName} (${data.policePhone})",
                      ),
                      _row("PJ Lahan", "${data.picName} (${data.picPhone})"),
                      _row("Poktan", data.jumlahPoktan.toString()),
                      _row("Petani", "${data.jumlahPetani} Orang"),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // SECTION 3: KOMODITAS (REFACTORED)
                  _buildSection(Icons.grass, "Data Komoditas", Colors.green, [
                    _row("Jenis Lahan", data.jenisLahan),
                    _row("Luas", "${data.luasLahan.toStringAsFixed(2)} Ha"),
                    _row("Jenis Komoditi", data.komoditi),
                    _row(
                      "Nama Poktan",
                      data.keterangan,
                    ), // Mengambil dari kolom poktan
                  ]),
                  const SizedBox(height: 16),

                  // SECTION 4: DOKUMENTASI
                  _buildSection(
                    Icons.camera_alt_outlined,
                    "Dokumentasi Lahan",
                    Colors.purple,
                    [
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImageFromData(data.fotoLahan),
                      ),
                      if (data.fotoLahan.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "* Foto diproses langsung dari database dokumentasi",
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // SECTION 5: LOG AKTIVITAS (REFACTORED - GABUNG NAMA & TGL)
                  _buildSection(
                    Icons.history,
                    "Log Aktivitas",
                    Colors.blueGrey,
                    [
                      _row("Diproses Oleh", data.infoProses),
                      _row("Validasi Oleh", data.infoValidasi),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // TOMBOL AKSI
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Logika validasi data
                      },
                      child: const Text(
                        "VALIDASI DATA SEKARANG",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FUNGSI UNTUK MERUBAH TEKS SQL MENJADI GAMBAR (DENGAN PEMBERSIHAN DATA)
  Widget _buildImageFromData(String photoData) {
    if (photoData.isEmpty || photoData == "null") {
      return _emptyImage();
    }

    try {
      // 1. Bersihkan prefix data:image jika ada
      String cleanBase64 =
          photoData.contains(',') ? photoData.split(',').last : photoData;

      // 2. Bersihkan karakter ilegal (spasi, newline, carriage return)
      cleanBase64 = cleanBase64
          .trim()
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .replaceAll(' ', '');

      // 3. Tambahkan padding '=' jika panjang string tidak sesuai (Kelipatan 4)
      while (cleanBase64.length % 4 != 0) {
        cleanBase64 += '=';
      }

      Uint8List bytes = base64Decode(cleanBase64);

      return Image.memory(
        bytes,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _emptyImage(),
      );
    } catch (e) {
      return _emptyImage();
    }
  }

  Widget _emptyImage() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            "Belum ada foto dokumentasi",
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    IconData icon,
    String title,
    Color color,
    List<Widget> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...items,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty || value == "null" ? "-" : value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
