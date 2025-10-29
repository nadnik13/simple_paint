import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> init() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(iOS: DarwinInitializationSettings());
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notification) {},
    );
  }

  static Future<void> showNotification(String text) async {
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().second,
      null,
      text,
      null,
    );
  }
}
