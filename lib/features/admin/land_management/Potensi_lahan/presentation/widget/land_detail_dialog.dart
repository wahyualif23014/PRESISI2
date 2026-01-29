import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/data/model/land_potential_model.dart';

class LandDetailDialog extends StatelessWidget {
  final LandPotentialModel data;

  const LandDetailDialog({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. KARTU DATA
          Flexible(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow("KEPOLISIAN RESOR", data.resor),
                    _buildRow("KEPOLISIAN SEKTOR", data.sektor),
                    _buildRow("JENIS LAHAN", data.jenisLahan),
                    _buildRow("POLISI PENGGERAK", "${data.policeName} (${data.policePhone})"),
                    _buildRow("PENANGGUNG JAWAB", "${data.picName} (${data.picPhone})"),
                    _buildRow("KETERANGAN", data.keterangan),
                    _buildRow("Jumlah Poktan", data.jumlahPoktan.toString()),
                    _buildRow("Luas Lahan", "${data.luasLahan} Ha"),
                    _buildRow("Jumlah Petani", data.jumlahPetani.toString()),
                    _buildRow("Komoditi", data.komoditi),
                    _buildRow("Alamat Lahan", "${data.alamatLahan}\nKEC. ${data.kecamatan} KAB. ${data.kabupaten}"),
                    _buildRow("Wilayah Lahan", "Desa ${data.desa} Kecamatan ${data.kecamatan}\nKabupaten ${data.kabupaten}"),

                    const SizedBox(height: 12),
                    
                    // PETA (Placeholder Maps)
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        image: const DecorationImage(
                          image: NetworkImage("https://mt1.google.com/vt/lyrs=m&x=1325&y=3143&z=13"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // FOTO LAHAN
                    const Text(
                      "Foto Lahan",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                          image: NetworkImage(
                            (data.fotoLahan != null && data.fotoLahan!.isNotEmpty)
                                ? data.fotoLahan!
                                : "https://via.placeholder.com/200x120?text=No+Image" // Fallback jika foto null
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildRow("Keterangan Lain", data.keteranganLain),
                    _buildRow("Diproses Oleh", "${data.diprosesOleh} (${data.tglProses})"),
                    _buildRow("Divalidasi Oleh", "${data.divalidasiOleh} (${data.tglValidasi})"),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // 2. TOMBOL TUTUP
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            label: const Text("Tutup", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Baris Data
  Widget _buildRow(String label, String value) {
    // Jika value kosong dari backend (string kosong), tampilkan "-"
    final displayValue = value.trim().isEmpty ? "-" : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4, 
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 11, 
                color: Colors.black
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              displayValue,
              style: const TextStyle(
                fontWeight: FontWeight.w600, 
                fontSize: 11, 
                color: Colors.black87,
                height: 1.3
              ),
            ),
          ),
        ],
      ),
    );
  }
}