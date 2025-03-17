import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

class LocalNotificationService {
  static final notificationPlugin = FlutterLocalNotificationsPlugin();
  static bool isInitialized = false;
//Initialize local notifications
  static Future<void> initiLocalNotifications() async {
    final logger = Logger();
    if (isInitialized) return;
    try {
      //Settings for Android
      const initSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      //Settings for IOS
      const initSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      //init settings
      const initSettings = InitializationSettings(
        android: initSettingsAndroid,
        iOS: initSettingsIOS,
      );

      //finally initialize the plugin
      await notificationPlugin.initialize(initSettings);
      isInitialized = true;
      logger.i("Local notifications initialized succesfully.");
    } catch (e) {
      logger
          .e("An error has ocurred while initializing local notificaitons: $e");
    }
  }

//NOtifications detail setup
  static NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  //Show notification
  static Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
  //  final logger = Logger();

    return notificationPlugin.show(
      id,
      title,
      body,
      notificationDetails(),
    );
  }
}
