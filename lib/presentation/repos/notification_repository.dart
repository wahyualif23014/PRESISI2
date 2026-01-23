import 'package:sdmapp/presentation/models/notification_model.dart';


class NotificationRepository {
  List<NotificationModel> getDummyNotifications() {
    return List.generate(
      10,
      (index) => NotificationModel(
        title: "POLDA JAWA TIMUR",
        body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit dolor sit amet.",
        time: "1m ago.",
        badgeCount: 2,
      ),
    );
  }
}