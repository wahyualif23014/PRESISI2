// features/admin/dashboard/data/repo/resapan_repository.dart
import '../model/resapan_model.dart'; 

class ResapanRepository {
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