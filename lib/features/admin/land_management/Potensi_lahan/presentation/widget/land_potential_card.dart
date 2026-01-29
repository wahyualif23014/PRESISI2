import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/data/model/land_potential_model.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/land_detail_dialog.dart';

class LandPotentialCard extends StatelessWidget {
  final LandPotentialModel data;

  const LandPotentialCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => LandDetailDialog(data: data),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === KOLOM 1: INFORMASI PERSONEL (POLISI & PJ) ===
                Expanded(
                  flex: 4, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPersonInfo("POLISI PENGGERAK", data.policeName, data.policePhone),
                      
                      // --- TAMBAHAN: Garis Pembatas Horizontal ---
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(
                          color: Colors.black26, // Warna garis agak gelap
                          thickness: 1,          // Ketebalan garis
                          height: 1,             // Tinggi container garis
                        ),
                      ),
                      // ------------------------------------------

                      _buildPersonInfo("PENANGGUNG JAWAB", data.picName, data.picPhone),
                    ],
                  ),
                ),

                const SizedBox(width: 12), // Jarak antar kolom diperlebar sedikit agar rapi

                // === KOLOM 2: ALAMAT ===
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ALAMAT LAHAN",
                        style: TextStyle(
                          fontSize: 9, 
                          color: Colors.grey, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.alamatLahan,
                        style: const TextStyle(
                          fontSize: 11, 
                          color: Colors.black87,
                          height: 1.4, 
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // === KOLOM 3: STATUS & ACTION FRAME ===
                Expanded(
                  flex: 4, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 1. Status Badge
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: data.statusValidasi == 'TERVALIDASI' 
                              ? const Color(0xFFE8F5E9) 
                              : const Color(0xFFFFF3E0), 
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: data.statusValidasi == 'TERVALIDASI' 
                              ? Colors.green 
                              : Colors.orange,
                            width: 1
                          )
                        ),
                        child: Text(
                          data.statusValidasi,
                          style: TextStyle(
                            color: data.statusValidasi == 'TERVALIDASI' 
                              ? Colors.green[700] 
                              : Colors.orange[800],
                            fontSize: 10, 
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // 2. Action Frame
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(Icons.storage_rounded, Colors.teal, "Data"),
                            _buildVerticalDivider(),
                            _buildActionButton(Icons.edit_rounded, Colors.blue, "Edit"),
                            _buildVerticalDivider(),
                            _buildActionButton(Icons.delete_outline_rounded, Colors.red, "Hapus"),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper: Divider kecil vertikal antar tombol
  Widget _buildVerticalDivider() {
    return Container(
      height: 16,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  // Widget Helper: Info Personel
  Widget _buildPersonInfo(String label, String name, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black87),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          phone,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Widget Helper: Tombol Aksi
  Widget _buildActionButton(IconData icon, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          // TODO: Tambahkan aksi di sini
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}