import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/data/model/land_potential_model.dart';

class LandPotentialCard extends StatelessWidget {
  final LandPotentialModel data;

  const LandPotentialCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2), // Jarak antar item tipis
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KOLOM 1: Polisi Penggerak
          Expanded(
            flex: 2,
            child: _buildPersonInfo(data.policeName, data.policePhone),
          ),
          
          // KOLOM 2: Penanggung Jawab (PJ)
          Expanded(
            flex: 2,
            child: _buildPersonInfo(data.picName, data.picPhone),
          ),
          
          Expanded(
            flex: 3,
            child: Text(
              data.address,
              style: const TextStyle(fontSize: 10, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // KOLOM 4: Status & Aksi
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Badge Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: data.statusValidasi == 'TERVALIDASI' 
                        ? Colors.green 
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    data.statusValidasi,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 9, 
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Action Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildIcon(Icons.visibility, Colors.blue), // Icon Mata
                    const SizedBox(width: 4),
                    _buildIcon(Icons.storage, Colors.green),   // Icon Database
                    const SizedBox(width: 4),
                    _buildIcon(Icons.edit, Colors.blue),       // Icon Edit
                    const SizedBox(width: 4),
                    _buildIcon(Icons.delete, Colors.red),      // Icon Hapus
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget: Info Orang (Nama & HP)
  Widget _buildPersonInfo(String name, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
        Text(
          phone,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  // Helper Widget: Icon Kecil
  Widget _buildIcon(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      child: Icon(icon, size: 18, color: color),
    );
  }
}