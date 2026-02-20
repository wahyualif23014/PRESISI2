import '../model/summary_item_model.dart'; // Pastikan path import sesuai

class SummaryRepository {
  
  List<SummaryItemModel> getSummaryData() {
    return [
      const SummaryItemModel(
        label: "Berhasil", 
        value: 90, 
        unit: "HA", 
        type: SummaryType.success
      ),
      const SummaryItemModel(
        label: "Gagal", 
        value: 10, // Variasi data biar terlihat beda
        unit: "HA", 
        type: SummaryType.failed
      ),
      const SummaryItemModel(
        label: "Tanam", 
        value: 120, 
        unit: "HA", 
        type: SummaryType.plant
      ),
      const SummaryItemModel(
        label: "Proses", 
        value: 45, 
        unit: "HA", 
        type: SummaryType.process
      ),
    ];
  }
}