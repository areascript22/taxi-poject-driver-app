import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:driver_app/features/home/repository/home_service.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/repositorie/local_notification_service.dart';
import 'package:driver_app/shared/repositorie/push_notification_service.dart';
import 'package:driver_app/shared/repositorie/shared_service.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as lc;
import 'package:logger/logger.dart';

class HomeViewModel extends ChangeNotifier {
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  final sharedUtil = SharedUtil();
  // Driver? driver;
  final Logger logger = Logger();
  lc.Location location = lc.Location();
  bool _loading = false;

  //LISTENERS
  StreamSubscription<ServiceStatus>? locationServicesAtSystemLevelListener;
  StreamSubscription<Position>? locationListener;
  StreamSubscription<DatabaseEvent>? deliveryRequestLitener;
  StreamSubscription<DatabaseEvent>? pendingRequestsLitener;
  StreamSubscription<DatabaseEvent>?
      requestAssignedListener; //When a driver is asigned to a request
  StreamSubscription<List<ConnectivityResult>>? connectivityListener;

  bool _locationPermissionsSystemLevel = true; //Location services System level
  bool _locationPermissionUserLevel = false; // Location services at User level
  bool _isCurrentLocationAvailable = true;
  bool _isThereInternetConnection = true;
  bool _toggleValue = false;

  final connectivity = Connectivity();

  int _currentPageIndex = 0;
  int _deliveryRequestLength = 0;
  int tempDeliveryrequest = 0;
  int _pendingRequestLength = 0;
  int tempPendingRequestLenght = 0;

  //GETTERS
  bool get loading => _loading;
  bool get isCurrentLocationAvailable => _isCurrentLocationAvailable;
  bool get isThereInternetConnection => _isThereInternetConnection;
  bool get locationPermissionsSystemLevel => _locationPermissionsSystemLevel;
  bool get locationPermissionUserLevel => _locationPermissionUserLevel;
  bool get toggleValue => _toggleValue;
  int get currentPageIndex => _currentPageIndex;
  int get deliveryRequestLength => _deliveryRequestLength;
  int get pendingRequestLength => _pendingRequestLength;

  //SETTERS
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  set locationPermissionsSystemLevel(bool value) {
    _locationPermissionsSystemLevel = value;
    notifyListeners();
  }

  set locationPermissionUserLevel(bool value) {
    _locationPermissionUserLevel = value;
    notifyListeners();
  }

  set isCurrentLocationAvailable(bool value) {
    _isCurrentLocationAvailable = value;
    notifyListeners();
  }

  set isThereInternetConnection(bool value) {
    _isThereInternetConnection = value;
    notifyListeners();
  }

  set toggleValue(bool value) {
    _toggleValue = value;
    notifyListeners();
  }

  set currentPageIndex(int value) {
    _currentPageIndex = value;
    notifyListeners();
  }

  set deliveryRequestLength(int value) {
    _deliveryRequestLength = value;
    notifyListeners();
  }

  set pendingRequestLength(int value) {
    _pendingRequestLength = value;
    notifyListeners();
  }

  //FUNCTIONS
  void clearListeners() {
    locationServicesAtSystemLevelListener?.cancel();
    locationListener?.cancel();
    deliveryRequestLitener?.cancel();
    requestAssignedListener?.cancel();
    connectivityListener?.cancel();
  }

  //Sign out
  Future<void> signOut() async {
    loading = true;
    await SharedService.signOut();
    loading = false;
  }

  //Update Driver Status (pending, offline)
  Future<bool> goOnlineOrOffline(String availavility, String driverRideStatus,
      SharedProvider sharedProvider) async {
    if (!isThereInternetConnection) {
      return false;
    }
    if (availavility == Availability.offline) {
      final success = await SharedService.freeUpDriverPositionInQueue();
      if (success) {
        final udaSuccess = await HomeService.updateDriverAvailability(
            availavility, driverRideStatus);
        if (udaSuccess) {
          return await SharedService.removeCurrentDriver();
        } else {
          return false;
        }
      } else {
        return false;
      }
    }

    if (availavility == Availability.online) {
      return await HomeService.writeInitialDriverInfo(sharedProvider);
    } else {
      return false;
    }
  }

  //To make sure every drivers knows when a request is assigned
  void listenToRequestAssigned() async {
    try {
      final driverId = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseDatabase.instance.ref('assignedRequests');
      requestAssignedListener = ref.onChildAdded.listen((event) async {
        //get driver id
        final tempDriverId = event.snapshot.key as String;
        logger.f("value to notify all: $tempDriverId }");

        if (tempDriverId != driverId) {
          await sharedUtil.playAudioOnce('sounds/new_assigned_ride.mp3');
          await LocalNotificationService.showNotification(
              title: 'Una carrera ha sido asignada');
        }
      });
    } catch (e) {
      logger.e("Asigned driver listener: $e");
    }
  }

  //Check internet connection
  void listenToInternetConnection() {
    connectivityListener = connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> event) {
      if (event.isEmpty || event.contains(ConnectivityResult.none)) {
        isThereInternetConnection = false;
      } else {
        isThereInternetConnection = true;
        logger.f("THERE IS CONNECTION");
      }
    });
  }

  void initializeNotifications(SharedProvider sharedProvider) async {
    // _setDeviceToken(sharedProvider);
    await LocalNotificationService.initiLocalNotifications();
    _setDeviceToken(sharedProvider);
  }

  //set device token to send Push notification (saved in Firestore)
  void _setDeviceToken(SharedProvider sharedProvider) async {
    if (sharedProvider.currentDeviceToken != null) {
      return;
    }
    String? deviceToken = await PushNotificationService.getDeviceToken();
    //store it locally
    if (deviceToken != null) {
      sharedProvider.driver!.deviceToken = deviceToken;
      //udpate the value in Firestore
      await HomeService.updateDeviceToken(deviceToken);
      // await HomeService.updateDeviceTokenInFRD(deviceToken);
  //    await PushNotificationService.setupNotificationChannel();
      sharedProvider.currentDeviceToken = deviceToken;
    }
  }

  //get issue bassed on priority
  Map? getIssueBassedOnPriority() {
    if (!isThereInternetConnection) {
      return {
        "priority": 0,
        "color": Colors.red,
        "title": "Sin conexión a internet",
        "content": "Conectate a internet para continuar",
      };
    }
    if (!locationPermissionUserLevel) {
      return {
        "priority": 1,
        "color": Colors.red,
        "title": "Permisos de ubicación desactivados.",
        "content": "Click aquí para activarlos",
      };
    }
    if (!locationPermissionsSystemLevel) {
      return {
        "priority": 2,
        "color": Colors.orange,
        "title": "Servicio de ubicación desactivados.",
        "content": "Click aquí para activarlo.",
      };
    }
    if (!isCurrentLocationAvailable) {
      return {
        "priority": 3,
        "color": Colors.white70,
        "title": "Te estamos buscando en el mapa.",
        "content": "Sin señal GPS.",
      };
    }
    return null;
  }

  // To listen only Delivery request lenght
  void listenToDeliveryRequests(DatabaseReference requestsRef) {
    final SharedUtil sharedUtil = SharedUtil();
    deliveryRequestLitener = requestsRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        // Filter pending requests
        List<MapEntry<dynamic, dynamic>> entries = data.entries
            .where((entry) => entry.value['status'] == 'pending')
            .toList();
        deliveryRequestLength = entries.length;

        if (tempDeliveryrequest != deliveryRequestLength) {
          tempDeliveryrequest = deliveryRequestLength;
          //Play sound and vibrate phone every time there is a new delivery
          if (tempDeliveryrequest != 0) {
            sharedUtil.playAudioOnce("sounds/new_delivery.mp3");
            sharedUtil.makePhoneVibrate();
          }
        }
      } else {
        tempDeliveryrequest = 0;
        deliveryRequestLength = 0;
      }
    });
  }

  // To listen only pending ride request lenght
  void listenToPendingRideRequests(DatabaseReference requestsRef) {
    pendingRequestsLitener = requestsRef.onValue.listen((event) {
      final SharedUtil sharedUtil = SharedUtil();
      final data = event.snapshot.value as Map?;
      if (data != null) {
        // Filter pending requests
        List<MapEntry<dynamic, dynamic>> entries = data.entries
            // .where((entry) => entry.value['status'] == 'pending')
            .toList();
        pendingRequestLength = entries.length;

        if (tempPendingRequestLenght != pendingRequestLength) {
          tempPendingRequestLenght = pendingRequestLength;
          //Play sound and vibrate phone every time there is a new delivery
          if (tempPendingRequestLenght != 0) {
            sharedUtil.playAudioOnce("sounds/pending_ride.mp3");
            sharedUtil.makePhoneVibrate();
          }
        }
      } else {
        tempPendingRequestLenght = 0;
        pendingRequestLength = 0;
      }
    });
  }

  //Check GPS permissions
  Future<bool> checkGpsPermissions(SharedProvider sharedProvider) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      locationPermissionsSystemLevel = false;
      return false;
    }

    // Check the app's location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // App does not have location permissions
      locationPermissionUserLevel = false;
      return false;
    }

    // Location services are enabled and app has permissions
    locationPermissionUserLevel = true;
    // _startLocationTracking(sharedProvider);
    startLocationTracking(sharedProvider);
    return true;
  }

  // Function to start tracking location changes
  void startLocationTracking(SharedProvider sharedProvider) async {
    //Write Driver initial data
    // await HomeService.writeInitialDriverInfo(sharedProvider);
    //Initialize Background services

    locationListener?.cancel();
    isCurrentLocationAvailable = false;
    //FIRST try to get last known position

    Position? cPosition = await Geolocator.getLastKnownPosition();
    if (cPosition != null) {
      logger.f("Last known position Catched");
      sharedProvider.driverCurrentPosition = cPosition;
      isCurrentLocationAvailable = true;
      // await HomeService.updateDriverCurrentLocationInFirebase(cPosition);
      //setDeviceToken(sharedProvider);
    }
    //THEN try to get the current positio
    try {
      // Get the current location
      Position currentPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low)
          .timeout(const Duration(seconds: 5));
      //Update current position in Porvider
      sharedProvider.driverCurrentPosition = currentPosition;
      //  await HomeService.updateDriverCurrentLocationInFirebase(currentPosition);
      isCurrentLocationAvailable = true;
    } catch (e) {
      logger.e("Error tryng to Catch current location: $e");
    }

    // LISTENERE: Just to check either there is gps signal or not
    locationListener = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
    ).listen((Position position) async {
      // If location is available, update the flag to true
      isCurrentLocationAvailable = true;
      sharedProvider.driverCurrentPosition = position;
    }, onError: (error) {
      // If there is an error, update the flag to false
      isCurrentLocationAvailable = false;
      logger.e("Error Loistening location: $error");
    });
  }

  //request permissions
  Future<bool> requestPermissionsAtUserLevel(
      SharedProvider sharedProvider) async {
    // Check the app's location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request location permissions
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions denied
        locationPermissionUserLevel = false;
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, cannot request them
      try {
        await Geolocator.openAppSettings();
        // After opening settings, you can't recheck immediately
      } on PlatformException catch (e) {
        logger.i("Error opening app settings: $e");
        locationPermissionUserLevel = false;
        return false;
      }
      locationPermissionUserLevel = false;
      return false;
    }

    // If all checks pass, permissions are granted and location services are enabled
    locationPermissionUserLevel = true;
    // _startLocationTracking(sharedProvider);
    startLocationTracking(sharedProvider);
    return true;
  }

  /// Listens to changes in location service status
  void listenToLocationServicesAtSystemLevel() {
    locationServicesAtSystemLevelListener =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      locationPermissionsSystemLevel = (status == ServiceStatus.enabled);
    });
  }

  //Open Activate Lcoation Services Dialog
  Future<void> requestLocationServiceSystemLevel() async {
    bool serviceEnabled = await location.requestService();
    locationPermissionsSystemLevel = serviceEnabled;
  }
}
