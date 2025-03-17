import 'dart:async';
import 'dart:ui';
import 'package:driver_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

StreamSubscription<Position>? _positionStreamSubscription;

Future<void> startBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    //FOREGROUND SERVICE
    service.on('setAsForeground').listen((event) async {
      service.setAsForegroundService();
      //Start Tracking location
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 2,
        ),
      ).listen((position) async {
        await _updateLocationInFirebase(position);
        await service.setForegroundNotificationInfo(
          title: "Ubicación actual",
          content: "${position.latitude},${position.longitude}",
        );
      });
    });

    //BACKGROUND SERVICE
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

Future<void> _updateLocationInFirebase(
  Position position,
) async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) return;
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("drivers/$driverId/location");
    await ref.update({
      'latitude': position.latitude,
      'longitude': position.longitude,
      // 'timestamp': DateTime.now().toString(),
    });
    //GEOFRE
    // final locationRef = FirebaseDatabase.instance.ref('drivers_locations');
    // final geoFire = Geofire(locationRef);
    // geoFire.setLocation(driverId, GeoPoint(lat, lng));
  } catch (e) {
    print("Error: $e");
  }
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}
