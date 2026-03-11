import '../models/notification_model.dart';
import '../repos/notification_repository.dart';

class NotificationService {
  // Service memanggil Repository
  final NotificationRepository _repository = NotificationRepository();

  // Menyimpan ID notifikasi terakhir agar kita tahu jika ada yang baru
  int _lastNotificationId = 0; 

  /// 1. Mengambil dan memproses daftar notifikasi
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final notifications = await _repository.fetchNotifications();
      
      if (notifications.isNotEmpty) {
        // Update ID terakhir untuk sistem deteksi notifikasi baru (polling)
        _lastNotificationId = notifications.first.id;
      }

      return notifications;
    } catch (e) {
      print('Service Error (getNotifications): $e');
      throw Exception('Gagal memproses data notifikasi');
    }
  }

  /// 2. Mengambil dan memproses jumlah lonceng merah
  Future<int> getUnreadCount() async {
    try {
      final count = await _repository.fetchUnreadCount();
      return count;
    } catch (e) {
      print('Service Error (getUnreadCount): $e');
      return 0; // Kembalikan 0 jika gagal agar UI tidak crash
    }
  }

  /// 3. Mengecek apakah ada notifikasi baru (Bisa dipakai untuk trigger Popup HP)
  Future<bool> checkForNewNotifications() async {
    try {
      final notifications = await _repository.fetchNotifications();
      if (notifications.isNotEmpty) {
        final latestId = notifications.first.id;
        if (latestId > _lastNotificationId && _lastNotificationId != 0) {
          _lastNotificationId = latestId;
          return true; // Ada notifikasi baru!
        }
        _lastNotificationId = latestId;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}