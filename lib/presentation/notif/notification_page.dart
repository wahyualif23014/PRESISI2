import 'package:flutter/material.dart';
import 'models/notification_model.dart'; 
import 'repos/notification_repository.dart'; 
import 'widgets/notification_item_widget.dart'; // Import widget baru tadi

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> notifications = [];
  final NotificationRepository _repository = NotificationRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      notifications = _repository.getDummyNotifications();
    });
  }

  void _deleteItem(int index) {
    setState(() {
      notifications.removeAt(index);
    });
    
    // Opsional: Tampilkan feedback snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Notifikasi dihapus"), 
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2730),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "Notification",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("Tidak ada notifikasi"))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: notifications.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Colors.transparent),
              itemBuilder: (context, index) {
                final item = notifications[index];

                // PANGGIL WIDGET DI SINI
                return NotificationItemWidget(
                  item: item,
                  // Kirim fungsi hapus ke widget anak
                  onRemove: () => _deleteItem(index),
                );
              },
            ),
    );
  }
}