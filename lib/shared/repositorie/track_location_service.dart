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
import 'package:logger/logger.dart';

StreamSubscription<Position>? _positionStreamSubscription;
SharedUtil sharedUtil = SharedUtil();
StreamSubscription<DatabaseEvent>? onPendingRideRequestAdded;
StreamSubscription<DatabaseEvent>? onDriverInQueueAssigned;
StreamSubscription<DatabaseEvent>? onDeliveryReqeusted;
StreamSubscription<DatabaseEvent>? driverStatusListener;
String backgroundDriverId = 'default';

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
  final logger = Logger();
  logger.f("Inicialianzo Foreground Service");

  if (service is AndroidServiceInstance) {
    //FOREGROUND SERVICE
    service.on('setAsForeground').listen((event) async {
      service.setAsForegroundService();
      //Show preview of persistence notification
      await service.setForegroundNotificationInfo(
        title: "Esperando ubicación...",
        content: "Conectando con el GPS...",
      );
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
          title: "Escuchando pedidos",
          content: "Funcionando en segundo plano",
        );
      }, onError: (error) async {
        await service.setForegroundNotificationInfo(
          title: "Problema de ubicación",
          content: "Revisa tu GPS para seguir recibiendo solicitudes",
        );
      });
    });

    //BACKGROUND SERVICE
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) async {
    await (service as AndroidServiceInstance).setForegroundNotificationInfo(
      title: "Servicio detenido",
      content: "No estás recibiendo pedidos",
    );
    _positionStreamSubscription?.cancel();
    onPendingRideRequestAdded?.cancel();
    onDriverInQueueAssigned?.cancel();
    onDeliveryReqeusted?.cancel();
    driverStatusListener?.cancel();
    await service.setAsBackgroundService();
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
  driverStatusListener?.cancel();
  //GEt provider
  //RIDE REQUEST TO A SECTOR
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final requestsRef = FirebaseDatabase.instance.ref('driver_requests');
  onPendingRideRequestAdded = requestsRef.onChildAdded.listen((event) {
    final value = event.snapshot.value as Map;
    final sector = value['sector'];
    //Play audio only if driver has no trips in progress
    if (SharedProvider.driverRideStatusS == DriverRideStatus.pending) {
  
      if (sector != null) {
        sharedUtil.speakSectorName('Carrera al sector ${sector!}');
      } else {
        sharedUtil.playAudioOnce("sounds/pending_ride.mp3");
      }
      sharedUtil.makePhoneVibrate();
    }
  });

  //DELIVERY REQUEST
  final deliveryRef = FirebaseDatabase.instance.ref('delivery_requests');
  onDeliveryReqeusted = deliveryRef.onChildAdded.listen((event) {
    if (event.snapshot.exists) {
      sharedUtil.playAudioOnce("sounds/new_delivery.mp3");
      sharedUtil.makePhoneVibrate();
    }
  });

  // //STATUS LSITENER: To listen trip canceled
  final driverId = FirebaseAuth.instance.currentUser?.uid;
  if (driverId != null) {
    final databaseRefStatus =
        FirebaseDatabase.instance.ref('drivers/$driverId/status');
    driverStatusListener = databaseRefStatus.onValue.listen((event) {
      if (event.snapshot.exists) {
        final status = event.snapshot.value as String;
        if (status == DriverRideStatus.canceled) {
          sharedUtil.playAudioOnce("sounds/ride_canceled.mp3");
          sharedUtil.makePhoneVibrate();
        }
      }
    });
  }
}

//IOS
@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}
