import 'package:flutter/services.dart';

class AppLifecycleManager {
  static const platform =
      MethodChannel('com.yourcompany.app/foregroundService');

  static Future<void> bringAppToForeground() async {
    try {
      await platform.invokeMethod('bringAppToForeground');
    } on PlatformException catch (e) {
      print("Error al intentar traer la app a primer plano: ${e.message}");
    }
  }
}
