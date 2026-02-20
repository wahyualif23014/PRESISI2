import '../model/resapan_model.dart'; // Pastikan path import sesuai

class ResapanRepository {
  
  // Method untuk mengambil data dummy Resapan
  ResapanModel getResapanData() {
    return ResapanModel(
      year: "2026",
      total: 340,
      items: [
        ResapanItem(label: "Resapan Bulog", value: 170),
        ResapanItem(label: "Resapan Tengkulak", value: 80),
        ResapanItem(label: "Resapan Lainnya", value: 90),
      ],
    );
  }
}