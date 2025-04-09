//
import 'dart:async';
import 'dart:ui';
import 'package:driver_app/firebase_options.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

StreamSubscription<Position>? _positionStreamSubscription;
SharedUtil sharedUtil = SharedUtil();
StreamSubscription<DatabaseEvent>? onPendingRideRequestAdded;
StreamSubscription<DatabaseEvent>? onDriverInQueueAssigned;
StreamSubscription<DatabaseEvent>? onDeliveryReqeusted;

Future<void> startBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false, // Asegura que el servicio se inicie automáticamente
      isForegroundMode: true, // Activa el modo foreground
      initialNotificationTitle: "Servicio Activo",
      initialNotificationContent: "El servicio está ejecutándose...",
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
      //
      startPendingRequestListener();
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
    onPendingRideRequestAdded?.cancel();
    onDriverInQueueAssigned?.cancel();
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
    });
  } catch (e) {
    print("Error: $e");
  }
}

//
void startPendingRequestListener() async {
  onDriverInQueueAssigned?.cancel();
  onPendingRideRequestAdded?.cancel();
  //GEt provider
  //RIDE REQUEST TO A SECTOR
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final requestsRef = FirebaseDatabase.instance.ref('driver_requests');
  onPendingRideRequestAdded = requestsRef.onChildAdded.listen((event) {
    final value = event.snapshot.value as Map;
    final sector = value['sector'];
    if (SharedProvider.driverRideStatusS == DriverRideStatus.pending) {
      if (sector != null) {
        sharedUtil.speakSectorName('Carrera al sector ${sector!}');
      } else {
        sharedUtil.playAudioOnce("sounds/pending_ride.mp3");
      }
      sharedUtil.makePhoneVibrate();
    }
  });

  //RIDE REQUEST TO THE QUEUE
  // final uid = FirebaseAuth.instance.currentUser?.uid;
  // if (uid == null) {
  //   print("User is not authenticated");
  //   return;
  // }
  // final ref = FirebaseDatabase.instance.ref("drivers/$uid/passenger");
  // onDriverInQueueAssigned = ref.onValue.listen((event) {
  //   if (event.snapshot.exists) {
  //     sharedUtil.playAudioOnce("sounds/pending_ride.mp3");
  //     sharedUtil.makePhoneVibrate();
  //   }
  // });

  //DELIVERY REQUEST
  final deliveryRef = FirebaseDatabase.instance.ref('delivery_requests');
  onDeliveryReqeusted = deliveryRef.onChildAdded.listen((event) {
    if (event.snapshot.exists) {
      sharedUtil.playAudioOnce("sounds/new_delivery.mp3");
      sharedUtil.makePhoneVibrate();
    }
  });
}

//IOS
@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}
