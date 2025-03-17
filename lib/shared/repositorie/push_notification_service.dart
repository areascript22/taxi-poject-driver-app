import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  // Instancia del plugin de notificaciones locales
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Función estática para inicializar el canal de notificación
  static Future<void> initializeNotificationChannel() async {
    // Crear un canal de notificación de alta prioridad
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // ID del canal
      'High Importance Notifications', // Nombre del canal

      importance: Importance.high, // Prioridad alta
      playSound: true, // Reproducir sonido
    );

    // Crear el canal en el dispositivo
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  //permissions
  static Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    print("PERMISSION STATUS: ${settings.authorizationStatus}");
  }

  //Get device token
  static Future<String?> getDeviceToken() async {
    // NotificationSettings settings =
    //     await FirebaseMessaging.instance.requestPermission(sound: true);
    String? deviceToken = await FirebaseMessaging.instance.getToken();
    return deviceToken;
  }

  static Future<void> sendPushNotification({
    required String deviceToken,
    required String title,
    required String body,
    String? tripID,
  }) async {
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('sendPushNotification');

      final response = await callable.call({
        'token': deviceToken,
        'title': title,
        'body': body,
      });

      print('✅ Notificación enviada: ${response.data}');
    } on FirebaseFunctionsException catch (e) {
      print('❌ Error en la función: ${e.message} ');
    } catch (e) {
      print('❌ Error inesperado: $e');
    }
  }
}

//lsitener
void listenToBackgroundMessages() {
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
}

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  print('Background Message: ${message.notification?.title}');
  // Este bloque asegura que la app esté en primer plano al recibir la notificación

  try {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  } catch (e) {
    print('Error al traer la app al frente: $e');
  }
}
