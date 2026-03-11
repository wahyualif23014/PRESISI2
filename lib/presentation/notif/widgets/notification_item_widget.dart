import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationModel item;

  const NotificationItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              item.time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          // Aksi jika notifikasi di klik (opsional)
        },
      ),
    );
  }
}