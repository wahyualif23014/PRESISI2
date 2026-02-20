import '../model/kwartal_item_model.dart'; // Pastikan path import ini sesuai dengan lokasi model Anda

class QuarterlyRepository {
  
  // Method untuk mengambil list data dummy kwartal
  List<QuarterlyItem> getQuarterlyData() {
    return [
      // --- KWARTAL 1 ---
      QuarterlyItem(
        value: 90, 
        unit: "HA", 
        label: "Tanam Lahan Produktif", 
        period: "Kwartal 1"
      ),
      QuarterlyItem(
        value: 10, 
        unit: "HA", 
        label: "Tanam Lahan Perhutanan", 
        period: "Kwartal 1"
      ),
      QuarterlyItem(
        value: 32, 
        unit: "HA", 
        label: "Tanam Lahan LBS", 
        period: "Kwartal 1"
      ),
      QuarterlyItem(
        value: 8, 
        unit: "HA", 
        label: "Tanam Lahan Pesantren", 
        period: "Kwartal 1"
      ),

      // --- KWARTAL 2 ---
      QuarterlyItem(
        value: 120, 
        unit: "HA", 
        label: "Perluasan Lahan Produktif", 
        period: "Kwartal 2"
      ),
      QuarterlyItem(
        value: 45, 
        unit: "HA", 
        label: "Tanam Lahan Pesantren", 
        period: "Kwartal 2"
      ),

      // --- KWARTAL 3 ---
      QuarterlyItem(
        value: 200, 
        unit: "HA", 
        label: "Panen Raya Jagung", 
        period: "Kwartal 3"
      ),

      // --- KWARTAL 4 ---
      QuarterlyItem(
        value: 300, 
        unit: "HA", 
        label: "Evaluasi Akhir Tahun", 
        period: "Kwartal 4"
      ),
    ];
  }
}