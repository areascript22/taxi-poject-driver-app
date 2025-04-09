import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/ride_request/repository/ride_request_service.dart';
import 'package:driver_app/features/ride_request/utils/ride_history_util.dart';
import 'package:driver_app/shared/widgets/bottom_sheeet_star_ratings.dart';
import 'package:driver_app/shared/models/delivery_request_model.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/models/passenger_request.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/models/ride_history_model.dart';
import 'package:driver_app/shared/models/route_info.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/repositorie/shared_service.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:driver_app/shared/widgets/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';

class RideRequestViewModel extends ChangeNotifier {
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  final Logger logger = Logger();
  bool _loading = false;
  // final RideRequestService realtimeDBService = RideRequestService();
  final SharedUtil sharedUtil = SharedUtil();
  BuildContext? rideRequestPageContext;
  //For map
  Completer<GoogleMapController> mapController = Completer();
  Polyline _polylineFromPickUpToDropOff =
      const Polyline(polylineId: PolylineId("default"));
  Set<Marker> _markers = {};
  Map<MarkerId, Marker> driversMarkers = {};
  PassengerInformation? _passengerInformation;
  String? passengerId;
  PassengerRequest? _secondPassenger;
  String _driverRideStatus = '';
  LatLng? driverCurrenPosition;
  int? _routeDuration; //For the CountDown timer

  //For ride
  Timestamp? startTime;

  //For Driver Queue Positions
  bool _driverInQueue = false;
  int? _currenQueuePoosition;
  int? myPosition;

  //To handle request Type
  String? _requestType;
  String byTextIndications = '';
  String byAudioIndicationsURL = '';

  //for listeners
  StreamSubscription<DatabaseEvent>? driverPositionListener;
  StreamSubscription<DatabaseEvent>? passengerRequestListener;
  StreamSubscription<DatabaseEvent>? secondPassengerRequestListener;
  StreamSubscription<DatabaseEvent>? driverStatusListener;
  StreamSubscription<DatabaseEvent>? driverAvailabilityListener;
  StreamSubscription<DatabaseEvent>? secondPassengerCancelingListener;
  StreamSubscription<DatabaseEvent>? listenToAllDriversLocation;

  //For icons
  BitmapDescriptor? taxiIcon;
  Marker? _taxiMarker;

  //GETTERS
  bool get loading => _loading;
  bool get driverInQueue => _driverInQueue;
  int? get currenQueuePoosition => _currenQueuePoosition;
  Polyline get polylineFromPickUpToDropOff => _polylineFromPickUpToDropOff;
  Set<Marker> get markers => _markers;
  PassengerInformation? get passengerInformation => _passengerInformation;
  PassengerRequest? get secondPassenger => _secondPassenger;
  String get driverRideStatus => _driverRideStatus;
  String? get requestType => _requestType;
  Marker? get taxiMarker => _taxiMarker;
  int? get routeDuration => _routeDuration;

  //SETTERS
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  set driverInQueue(bool value) {
    _driverInQueue = value;
    notifyListeners();
  }

  set currenQueuePoosition(int? value) {
    _currenQueuePoosition = value;
    notifyListeners();
  }

  set polylineFromPickUpToDropOff(Polyline value) {
    _polylineFromPickUpToDropOff = value;
    notifyListeners();
  }

  set markers(Set<Marker> value) {
    _markers = value;
    notifyListeners();
  }

  set passengerInformation(PassengerInformation? value) {
    _passengerInformation = value;
    notifyListeners();
  }

  set secondPassenger(PassengerRequest? value) {
    _secondPassenger = value;
    notifyListeners();
  }

  set driverRideStatus(String value) {
    _driverRideStatus = value;
    notifyListeners();
  }

  set requestType(String? value) {
    _requestType = value;
    notifyListeners();
  }

  set taxiMarker(Marker? value) {
    _taxiMarker = value;
    notifyListeners();
  }

  set routeDuration(int? value) {
    _routeDuration = value;
    notifyListeners();
  }

  //Functinons
  void cancelListeners() {
    driverPositionListener?.cancel();
    passengerRequestListener?.cancel();
    secondPassengerRequestListener?.cancel();
    driverStatusListener?.cancel();
    driverAvailabilityListener?.cancel();
    listenToAllDriversLocation?.cancel();
  }

  //display all drivers
  void listenToAllDriversPositions() {
    final driverRef = FirebaseDatabase.instance.ref('drivers');
    listenToAllDriversLocation = driverRef.onValue.listen((event) async {
      String? driverID = FirebaseAuth.instance.currentUser?.uid;
      if (driverID == null) {
        return;
      }
      final data = event.snapshot.value as Map?;
      // logger.f("LASDFSA  ${data?.entries}");
      if (data == null) return;
      Map<MarkerId, Marker> tempmarkers = {};
      try {
        for (var entry in data.entries) {
          // logger.f('ENTRY: $entry');
          final driverId = entry.key;
          if (driverId == driverID) {
            continue;
          }
          final driverData = entry.value as Map;
          final location = driverData['location'];
          final driverInfo = driverData['information'];
          final taxiCode = driverInfo['taxiCode'];
          final driverName = driverInfo['name'];
          final vehicleModel = driverInfo['vehicleModel'];
          final lat = double.tryParse(location['latitude'].toString());
          final lng = double.tryParse(location['longitude'].toString());
          if (lat != null && lng != null) {
            final markerIcon =
                await _createCustomMarkerBitmap(taxiCode.toString());
            final markerId = MarkerId(driverId);
            final marker = Marker(
              markerId: markerId,
              infoWindow: InfoWindow(title: driverName, snippet: vehicleModel),
              position: LatLng(lat, lng),
              icon: markerIcon,
              // icon: BitmapDescriptor.defaultMarker,
            );

            tempmarkers[markerId] = marker;
          }
        }
      } catch (e) {
        logger.e('error: $e');
      }
      driversMarkers = tempmarkers;
      notifyListeners();
    });
  }

  Future<BitmapDescriptor> _createCustomMarkerBitmap(String number) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.red;

    const double radius = 90.0;

    // Draw a circle
    canvas.drawCircle(const Offset(radius / 2, radius / 2), radius / 2, paint);

    // Draw number text
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: number,
        style: const TextStyle(
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset((radius - textPainter.width) / 2,
            (radius - textPainter.height) / 2));

    final img = await pictureRecorder
        .endRecording()
        .toImage(radius.toInt(), radius.toInt());
    final data = await img.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  //fit all markers on the map
  Future<void> fitMarkers(SharedProvider sharedProvider) async {
    // Check if pick-up and drop-off coordinates are not null
    try {
      if (passengerInformation == null ||
          sharedProvider.driverCurrentPosition == null) {
        return;
      }
      LatLng p1;
      if (requestType == RequestType.byCoordinates) {
        p1 = passengerInformation!.pickUpCoordinates;
      } else {
        p1 = passengerInformation!.currentCoordenates;
      }

      LatLng p2 = LatLng(sharedProvider.driverCurrentPosition!.latitude,
          sharedProvider.driverCurrentPosition!.longitude);

      GoogleMapController controller = await mapController.future;

      // Create LatLngBounds for the two points
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          p1.latitude < p2.latitude ? p1.latitude : p2.latitude,
          p1.longitude < p2.longitude ? p1.longitude : p2.longitude,
        ),
        northeast: LatLng(
          p1.latitude > p2.latitude ? p1.latitude : p2.latitude,
          p1.longitude > p2.longitude ? p1.longitude : p2.longitude,
        ),
      );

      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100);
      await controller.animateCamera(cameraUpdate);
    } catch (e) {
      logger.e("Error trying to animate camera: $e");
    }
  }

  //Show all maps installed on the device to Navigate
  void showAvailableMaps(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    if (sharedProvider.driverCurrentPosition == null) {
      return;
    }
    Coords origin = Coords(sharedProvider.driverCurrentPosition!.latitude,
        sharedProvider.driverCurrentPosition!.longitude);
    if (sharedProvider.driverRideStatus == DriverRideStatus.goingToPickUp) {
      if (requestType == RequestType.byCoordinates) {
        Coords destination = Coords(
            passengerInformation!.pickUpCoordinates.latitude,
            passengerInformation!.pickUpCoordinates.longitude);

        sharedProvider.showAllAvailableMaps(context, origin, destination);
      } else {
        Coords destiationTemp = Coords(
          passengerInformation!.currentCoordenates.latitude,
          passengerInformation!.currentCoordenates.longitude,
        );
        sharedProvider.showAllAvailableMaps(
          context,
          origin,
          destiationTemp,
        );
      }
    } else {
      if (driverCurrenPosition != null) {
        Coords destiationTemp = Coords(
            driverCurrenPosition!.latitude, driverCurrenPosition!.longitude);
        sharedProvider.showAllAvailableMaps(
          context,
          origin,
          destiationTemp,
        );
      }
    }
  }

  //Animate map camera to especic point
  Future<void> animateToLocation(LatLng target) async {
    if (!mapController.isCompleted) {
      return;
    }
    // Ensure the controller is available
    try {
      final GoogleMapController controller = await mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      logger.e("Error trying to animate camera: $e");
    }
  }

  //On map created
  void onMapCreated(GoogleMapController controller) async {
    if (!mapController.isCompleted) {
      mapController.complete(controller);
    }
  }

  //Icons
  void loadIcons() async {
    taxiIcon = await RideHistoryUtil.convertImageToBitmapDescriptor(
        'assets/img/taxi.png');
  }

  //LISTENER: To Redraw route when there is passenger info
  void listenToDriverCoordenatesInFirebase(SharedProvider sharedProvider) {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
      return;
    }
    final databaseRef =
        FirebaseDatabase.instance.ref('drivers/$driverId/location');

    try {
      driverPositionListener = databaseRef.onValue.listen((event) async {
        //Check if there is any data
        if (event.snapshot.exists) {
          //get coordinates
          final coords = event.snapshot.value as Map;
          final LatLng driverCurrentCoords = LatLng(
              coords['latitude'].toDouble(), coords['longitude'].toDouble());
          driverCurrenPosition = driverCurrentCoords;
          //Update Taxi Icon
          if (taxiIcon != null) {
            taxiMarker = Marker(
                markerId: const MarkerId("taxi_marker"),
                position: driverCurrentCoords,
                icon: taxiIcon!);
          }

          //When There is a passenger
          if (passengerInformation != null) {
            //Draw Polyline
            LatLng destination = passengerInformation!.dropOffCoordinates;
            if (driverRideStatus == DriverRideStatus.goingToPickUp) {
              destination = passengerInformation!.pickUpCoordinates;
            }
            await _drawRouteBetWeenCoords(driverCurrentCoords, destination);
          }
        }
      });
    } catch (e) {
      logger.e('Error listening to driver coordinates: $e');
    }
  }

  Future<RouteInfo?> _drawRouteBetWeenCoords(LatLng from, LatLng to) async {
    RouteInfo? routeInfo =
        await SharedService.getRoutePolylinePoints(from, to, apiKey);
    if (routeInfo != null) {
      polylineFromPickUpToDropOff = Polyline(
        polylineId: const PolylineId(""),
        points: routeInfo.polylinePoints,
        color: Colors.blue,
        width: 5,
      );
    }
    logger.f("Type of duration: ${routeInfo?.duration}");
    return routeInfo;
  }

  //LISTENER: To listen when a Passenger request Us
  void listenerToPassengerRequest(SharedProvider sharedProvider) {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
      return;
    }
    final databaseRef =
        FirebaseDatabase.instance.ref('drivers/$driverId/passenger');
    try {
      passengerRequestListener =
          databaseRef.onValue.listen((DatabaseEvent event) async {
        // Check if the snapshot has data
        if (event.snapshot.exists) {
          try {
            // Get the status value
            final dataCatched = event.snapshot.value as Map;
            final passangerInfo = dataCatched['information'];
            passengerId = dataCatched['passengerId'];
            requestType = dataCatched['type'];
            byAudioIndicationsURL = passangerInfo['audioFilePath'];
            byTextIndications = passangerInfo['indicationText'];

            final PassengerInformation tempPassengerInformation =
                PassengerInformation.fromMap(passangerInfo);

            //Update passenger information
            passengerInformation = tempPassengerInformation;
            startTime = Timestamp.now();

            //Update Driver ride status
            if (driverRideStatus == DriverRideStatus.pending ||
                driverRideStatus == DriverRideStatus.reserved ||
                driverRideStatus == DriverRideStatus.finished) {
              await updateDriverStatus(DriverRideStatus.goingToPickUp);
            }
            //Define Destination marker
            LatLng destinationPos;
            if (requestType == RequestType.byCoordinates) {
              destinationPos = tempPassengerInformation.pickUpCoordinates;
            } else {
              destinationPos = tempPassengerInformation.currentCoordenates;
            }
            //Add markers only if request type is 'byCoordinates'
            markers.add(
              Marker(
                markerId: const MarkerId("pick_up"),
                position: destinationPos,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              ),
            );

            //Draw route from taxi to pick up
            if (sharedProvider.driverCurrentPosition != null) {
              final LatLng driverPosition = LatLng(
                  sharedProvider.driverCurrentPosition!.latitude,
                  sharedProvider.driverCurrentPosition!.longitude);
              RouteInfo? routeInformation =
                  await _drawRouteBetWeenCoords(driverPosition, destinationPos);
              if (routeInformation != null) {
                routeDuration =
                    RideHistoryUtil.extractMinutes(routeInformation.duration);
              }
            }
            //Play sound
            // sharedUtil.playAudioOnce('sounds/nuevo_pedido.mp3');
            //Free up driver position in Queue
            freeUpDriverPositionInQueue();
            fitMarkers(sharedProvider);

            //NOtify all driver by writing our UId under assignedRequests
            await RideRequestService.notifyAllDrivers(driverId);
          } catch (e) {
            logger.e("Error trying ti get data : $e");
            passengerInformation = null;
          }
        } else {
          passengerInformation = null;
        }
      });
    } catch (e) {
      logger.e('Error listening passenger request: $e');
    }
  }

  //To listen another passenger.
  void listenToSecondPassangerRequest(SharedProvider sharedProvider) {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
      return;
    }
    final databaseRef =
        FirebaseDatabase.instance.ref('drivers/$driverId/secondPassenger');
    secondPassengerRequestListener = databaseRef.onValue.listen((event) {
      // Check if the snapshot has data
      if (event.snapshot.exists) {
        try {
          // Get the status value
          final dataCatched = event.snapshot.value as Map;
          final PassengerRequest tempPassengerInformation =
              PassengerRequest.fromMap(dataCatched);
          //Update passenger information
          secondPassenger = tempPassengerInformation;
          sharedProvider.secondPassenger = tempPassengerInformation;
          listenToSecondPassengerCanceling();
        } catch (e) {
          logger.e("Error trying to get data of second passenger: $e");
          secondPassenger = null;
          sharedProvider.secondPassenger = null;
        }
      } else {
        secondPassenger = null;
        sharedProvider.secondPassenger = null;
      }
    });
  }

  void listenToSecondPassengerCanceling() async {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
      return;
    }
    final ref = FirebaseDatabase.instance
        .ref('drivers/$driverId/secondPassenger/status');
    secondPassengerCancelingListener = ref.onValue.listen((event) async {
      if (event.snapshot.exists) {
        final status = event.snapshot.value as String;
        if (status == DriverRideStatus.canceled) {
          await cancelSecondRide();
        }
      }
    });
  }

  //LISTENER: to lsiten value changes under 'drivers/driverId/status'
  void listenToDriverStatus(
      SharedProvider sharedProvider, BuildContext context) async {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
      return;
    }

    final databaseRefStatus =
        FirebaseDatabase.instance.ref('drivers/$driverId/status');
    final databaseRefAvailability =
        FirebaseDatabase.instance.ref('drivers/$driverId/availability');
    await databaseRefAvailability.get();

    try {
      String availability = sharedProvider.availavilityState;

      //AVAILABILITY LISTENER
      driverAvailabilityListener =
          databaseRefAvailability.onValue.listen((event) {
        if (event.snapshot.exists) {
          final availavilityTemp = event.snapshot.value as String;
          availability = availavilityTemp;

          sharedProvider.availavilityState = availability;
        }
      });

      //STATUS LISTENER
      driverStatusListener =
          databaseRefStatus.onValue.listen((DatabaseEvent event) async {
        //check OCnnectivity

        // Check if the snapshot has data
        if (event.snapshot.exists) {
          //retrieve Status and Availavility
          // final values = event.snapshot.value as Map;
          // final availability = values['availability'] as String;
          // Get the status value
          final status = event.snapshot.value as String;
          switch (status) {
            case DriverRideStatus.goingToPickUp:
              driverRideStatus = DriverRideStatus.goingToPickUp;
              sharedProvider.driverRideStatus = DriverRideStatus.goingToPickUp;
              await RideRequestService.updateDriverAvailability(
                driverId,
                driverRideStatus,
                availability,
              );
              break;
            case DriverRideStatus.arrived:
              driverRideStatus = DriverRideStatus.arrived;
              sharedProvider.driverRideStatus = DriverRideStatus.arrived;
              await RideRequestService.updateDriverAvailability(
                driverId,
                driverRideStatus,
                availability,
              );
              routeDuration = null;
              if (driverCurrenPosition != null &&
                  passengerInformation != null) {
                await _drawRouteBetWeenCoords(driverCurrenPosition!,
                    passengerInformation!.dropOffCoordinates);
              }

              break;
            case DriverRideStatus.goingToDropOff:
              driverRideStatus = DriverRideStatus.goingToDropOff;
              sharedProvider.driverRideStatus = DriverRideStatus.goingToDropOff;
              await RideRequestService.updateDriverAvailability(
                driverId,
                driverRideStatus,
                availability,
              );
              break;
            case DriverRideStatus.reserved:
              driverRideStatus = DriverRideStatus.reserved;
              sharedProvider.driverRideStatus = DriverRideStatus.reserved;
              await RideRequestService.updateDriverAvailability(
                driverId,
                driverRideStatus,
                availability,
              );
              break;
            case DriverRideStatus.finished:
              routeDuration = null;
              driverRideStatus = DriverRideStatus.finished;
              sharedProvider.driverRideStatus = DriverRideStatus.finished;
              await RideRequestService.updateDriverAvailability(
                driverId,
                driverRideStatus,
                availability,
              );
              if (passengerId != null) {
                showStarRatingsBottomSheet(context, passengerId!);
              }
              markers.clear();
              polylineFromPickUpToDropOff =
                  const Polyline(polylineId: PolylineId("default"));
              //save ride history
              await _saveRideHistory(sharedProvider);
              passengerInformation = null;
              await RideRequestService.removePassengerInfo();
              //Check if there is a second passenger waiting
              if (secondPassenger != null) {
                await updateDriverStatus(DriverRideStatus.goingToPickUp);
                await RideRequestService.addPassengerDataToRequest(
                    secondPassenger!);
                await RideRequestService.removesecondPassengerInfo();
              } else {
                //Update to "pending" to be able to accept requests again
                await updateDriverStatus(DriverRideStatus.pending);
              }

              break;
            case DriverRideStatus.pending:
              driverRideStatus = DriverRideStatus.pending;
              sharedProvider.driverRideStatus = DriverRideStatus.pending;
              await RideRequestService.updateDriverAvailability(
                driverId,
                driverRideStatus,
                availability,
              );
              break;
            case DriverRideStatus.canceled:
              driverRideStatus = DriverRideStatus.canceled;
              sharedProvider.driverRideStatus = DriverRideStatus.canceled;
              passengerInformation = null;
              routeDuration = null;

              await RideRequestService.removePassengerInfo();
              markers.clear();
              polylineFromPickUpToDropOff =
                  const Polyline(polylineId: PolylineId("default"));
              routeDuration = null;
              await RideRequestService.updateDriverAvailability(
                driverId,
                driverRideStatus,
                availability,
              );
              //Check if there is a second passenger waiting
              if (secondPassenger != null) {
                await updateDriverStatus(DriverRideStatus.goingToPickUp);
                await RideRequestService.addPassengerDataToRequest(
                    secondPassenger!);
                await RideRequestService.removesecondPassengerInfo();
              } else {
                //Update to "pending" to be able to accept requests again
                await updateDriverStatus(DriverRideStatus.pending);
              }

              if (context.mounted) {
                ToastMessageUtil.showToast(
                    "La carrera ha sido cancelada", context);
              }
              break;
            default:
              logger.e("Driver Status not found..");
              break;
          }
        } else {
          logger.i('Driver $driverId status does not exist.');
        }
      });
    } catch (e) {
      logger.e('Error listening to driver status: $e');
    }
  }

  //Cancel ride
  Future<void> cancelRide() async {
    BuildContext context = rideRequestPageContext!;
    //Display the overlay
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => const LoadingOverlay(),
    );
    overlay.insert(overlayEntry);

    overlayEntry.remove();
  }

  Future<void> cancelSecondRide() async {
    BuildContext context = rideRequestPageContext!;
    //Display the overlay
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => const LoadingOverlay(),
    );
    overlay.insert(overlayEntry);
    await RideRequestService.removesecondPassengerInfo();
    secondPassengerCancelingListener?.cancel();
    overlayEntry.remove();
  }

  //Save ride history
  Future<void> _saveRideHistory(SharedProvider sharedProvider) async {
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("driver is not authenticated");
      return;
    }
    if (passengerId == null) {
      logger.e("There is not passenger");
      return;
    }
    try {
      RideHistoryModel rideHistory = RideHistoryModel(
        driverId: driverId,
        passengerId: passengerId!,
        pickupCoords: passengerInformation!.pickUpCoordinates,
        dropoffCoords: LatLng(
            sharedProvider.driverCurrentPosition?.latitude ?? 0.1,
            sharedProvider.driverCurrentPosition?.longitude ?? 0),
        pickUpLocation: passengerInformation?.pickUpLocation ?? 'n/a',
        startTime: startTime ?? Timestamp.now(),
        endTime: Timestamp.now(),
        passengerName: passengerInformation?.name ?? 'n/a',
        driverName: sharedProvider.driver?.name ?? 'n/a',
        status: driverRideStatus,
        requestType: requestType!,
        audioFilePath: passengerInformation!.audioFilePath,
        indicationText: passengerInformation!.indicationText,
        sector: sharedProvider.sector,
        timesTamp: DateTime.now(),
      );
      await RideRequestService.uploadRideHistory(rideHistory);
    } catch (e) {
      logger.e("Error trying to save ride history: $e");
    }
  }

  //Update 'status' field under 'drivers/driverID/status'
  Future<void> updateDriverStatus(String status) async {
    BuildContext context = rideRequestPageContext!;
    //Display the overlay
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => const LoadingOverlay(),
    );
    overlay.insert(overlayEntry);

    //get driver id
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
    } else {
      //Update Driver Status
      await RideRequestService.updateDriverStatus(driverId, status);
    }
    overlayEntry.remove();
  }

  //Remove driver position in Queue in realtime database
  void freeUpDriverPositionInQueue() async {
    await SharedService.freeUpDriverPositionInQueue();
    driverInQueue = false;
    currenQueuePoosition = null;
    myPosition = null;
  }

  //Book position in queue
  Future<void> bookPositionInQueue(SharedProvider sharedProvider) async {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not atuthenticated");
      return;
    }
    if (sharedProvider.driver != null) {
      driverInQueue = await RideRequestService.bookDriverPositionInQueue(
        idUsuario: driverId,
        taxiCode: sharedProvider.driver!.vehicle?.taxiCode ?? 'N/A',
        profilePicture: sharedProvider.driver?.profilePicture ?? '',
      );
    }
  }

//Stream to get drivers ordered bassed on timestamp field
  Stream<int?> getDriverPositionInQueue() {
    final String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("User not authenticated");
      return const Stream.empty();
    }
    final DatabaseReference driversRef =
        FirebaseDatabase.instance.ref('positions');
    return driversRef.onValue.map((event) {
      final drivers = event.snapshot.value as Map?;
      if (drivers != null) {
        // Convert the Map into a list of entries and sort by the Push() key (since it's based on timestamp-like behavior)
        final sortedDrivers = drivers.entries.toList()
          ..sort((a, b) {
            // Compare the keys (Push keys are ordered chronologically)
            return a.key.compareTo(b.key);
          });
        // Iterate over the sorted drivers and find the position of the current driver
        for (int i = 0; i < sortedDrivers.length; i++) {
          if (sortedDrivers[i].value['driver_id'] == driverId) {
            return i + 1; // Return the position (1-based index)
            // final current = sortedDrivers[i].value;
            // return {
            //   "index":i+1,
            //   "taxiCode":current['taxiCode'],
            // };
          }
        }
      }
      return null; // Return null if the driver is not in the queue
    });
  }

  //EmegencyNotification
  Future<void> sendEmergencyNotify(
      SharedProvider sharedProvider, BuildContext context) async {
    loading = true;
    final taxicode = sharedProvider.driver?.vehicle?.taxiCode;
    if (taxicode != null) {
      final response = await SharedService.emergencyNotification(taxicode);
      if (response && context.mounted) {
        ToastMessageUtil.showToast(
            "Notificación de emergencia enviada", context);
      }
    }

    loading = false;
  }
}
