class NotificationModel {
  final String title;
  final String body;
  final String time;
  final int badgeCount; // Untuk angka '2' di logo

  NotificationModel({
    required this.title,
    required this.body,
    required this.time,
    required this.badgeCount,
  });
}