class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String time;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      // Menggunakan default value jika null agar aplikasi tidak crash
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Tanpa Judul',
      body: json['body'] ?? 'Tanpa Keterangan',
      time: json['time'] ?? '',
    );
  }
}