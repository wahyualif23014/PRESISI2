import 'package:flutter/material.dart';
import '../../data/model/resapan_model.dart'; // Sesuaikan path

class ResapanCard extends StatelessWidget {
  final ResapanModel data;
  
  // Warna chart sesuai urutan data (Ungu, Biru, Orange)
  final List<Color> colors = const [
    Color(0xFFC084FC), // Ungu (Bulog)
    Color(0xFF2563EB), // Biru (Tengkulak)
    Color(0xFFF59E0B), // Orange (Lainnya)
  ];

  const ResapanCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. JUDUL
          Text(
            "Total Resapan Per Tahun ${data.year}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // 2. ANGKA TOTAL BESAR
          Text(
            "${data.total} HA",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // 3. HORIZONTAL STACKED BAR CHART
          ClipRRect(
            borderRadius: BorderRadius.circular(4), // Agar ujungnya tidak kotak tajam
            child: SizedBox(
              height: 40, // Tinggi bar chart
              child: Row(
                children: List.generate(data.items.length, (index) {
                  final item = data.items[index];
                  // Hitung flex berdasarkan value agar proporsional
                  // Jika value 0, beri flex 1 minimal agar tidak error, atau filter sebelumnya
                  final flex = item.value > 0 ? item.value : 1; 
                  
                  return Expanded(
                    flex: flex,
                    child: Container(
                      color: colors[index % colors.length],
                      // Tambahkan border putih tipis sebagai pemisah antar bar
                      margin: const EdgeInsets.only(right: 2), 
                    ),
                  );
                }),
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // 4. LEGEND (KETERANGAN DI BAWAH)
          Column(
            children: List.generate(data.items.length, (index) {
              final item = data.items[index];
              final color = colors[index % colors.length];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    // Dot Warna
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Label
                    Expanded(
                      child: Text(
                        "${item.label} Tahun ${data.year}", // Tambah tahun otomatis
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569), // Slate 600
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Value
                    Text(
                      "${item.value} HA",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}