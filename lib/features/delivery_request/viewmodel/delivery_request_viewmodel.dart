import 'dart:async';
import 'dart:io';

import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/delivery_request/model/delivery_status.dart';
import 'package:driver_app/features/delivery_request/repositorie/delivery_request_service.dart';
import 'package:driver_app/shared/models/delivery_request_model.dart';
import 'package:driver_app/shared/models/request_type.dart';
import 'package:driver_app/shared/models/route_info.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/repositorie/shared_service.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:driver_app/shared/widgets/bottom_sheeet_star_ratings.dart';
import 'package:driver_app/shared/widgets/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:map_launcher/map_launcher.dart';

class DeliveryRequestViewModel extends ChangeNotifier {
  final String apiKey = Platform.isAndroid
      ? dotenv.env['GOOGLE_MAPS_API_KEY_ANDROID'] ?? ''
      : dotenv.env['GOOGLE_MAPS_API_KEY_IOS'] ?? '';
  final Logger logger = Logger();
  final SharedUtil sharedUtil = SharedUtil();
  bool _loading = true;
  DeliveryRequestModel? _deliveryRequestModel;
  String _driverDeliveryStatus = '';
  Completer<GoogleMapController> mapController = Completer();
  Polyline _polylineFromPickUpToDropOff =
      const Polyline(polylineId: PolylineId("default"));
  Set<Marker> _markers = {};
  Marker _carMarker = const Marker(markerId: MarkerId('car_marker'));
  BitmapDescriptor? _carIcon;
  String? _mapMessages;
  BuildContext? deliveryRequestPageContext;
  LatLng? driverCurrentcoords;

  //for listeners
  StreamSubscription<DatabaseEvent>? driverPositionListener;
  StreamSubscription<DatabaseEvent>? passengerRequestListener;
  StreamSubscription<DatabaseEvent>? driverStatusListener;
  //To  avigate between delivery pages
  int _deliveryPageIndex = 0;

  //GETTERS
  bool get loading => _loading;
  DeliveryRequestModel? get deliveryRequestModel => _deliveryRequestModel;
  String get driverDeliveryStatus => _driverDeliveryStatus;
  BitmapDescriptor? get carIcon => _carIcon;
  Polyline get polylineFromPickUpToDropOff => _polylineFromPickUpToDropOff;
  Set<Marker> get markers => _markers;
  Marker get carMarker => _carMarker;
  String? get mapMessages => _mapMessages;
  int get deliveryPageIndex => _deliveryPageIndex;

  //SETTERS
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  set deliveryRequestModel(DeliveryRequestModel? value) {
    _deliveryRequestModel = value;
    notifyListeners();
  }

  set driverDeliveryStatus(String value) {
    _driverDeliveryStatus = value;
    notifyListeners();
  }

  set carIcon(BitmapDescriptor? value) {
    _carIcon = value;
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

  set carMarker(Marker value) {
    _carMarker = value;
    notifyListeners();
  }

  set mapMessages(String? value) {
    _mapMessages = value;
    notifyListeners();
  }

  set deliveryPageIndex(int value) {
    _deliveryPageIndex = value;
    notifyListeners();
  }

  //FUNCTIONS
  void cancelListeners() {
    driverPositionListener?.cancel();
    passengerRequestListener?.cancel();
    driverStatusListener?.cancel();
  }

  //On map created
  void onMapCreated(GoogleMapController controller) async {
    mapController = Completer();
    mapController.complete(controller);
  }

  //fit all markers
  //fit all markers on the map
  Future<void> fitMarkers(SharedProvider sharedProvider) async {
    try {
      // Check if pick-up and drop-off coordinates are not null
      if (deliveryRequestModel == null) {
        return;
      }
      LatLng p1;
      if (deliveryRequestModel!.requestType == RequestType.byCoordinates) {
        p1 = deliveryRequestModel!.information.pickUpCoordinates;
      } else {
        p1 = deliveryRequestModel!.information.currentCoordenates;
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



  //fit markers passed as parameters
  Future<void> fitMarkersToBounds({
    required List<LatLng> markers,
    required GoogleMapController mapController,
    double padding = 100.0,
  }) async {
    if (markers.isEmpty) return;

    try {
      // Inicializa los límites con el primer marcador
      double minLat = markers.first.latitude;
      double maxLat = markers.first.latitude;
      double minLng = markers.first.longitude;
      double maxLng = markers.first.longitude;

      // Recorre todos los marcadores para encontrar extremos
      for (var marker in markers) {
        if (marker.latitude < minLat) minLat = marker.latitude;
        if (marker.latitude > maxLat) maxLat = marker.latitude;
        if (marker.longitude < minLng) minLng = marker.longitude;
        if (marker.longitude > maxLng) maxLng = marker.longitude;
      }

      // Define los límites
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      // Aplica el movimiento de cámara con padding
      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, padding);
      await mapController.animateCamera(cameraUpdate);
    } catch (e) {
      print("Error al encajar los marcadores: $e");
    }
  }



  //Animate map camera to especic point
  Future<void> animateCameraToLocation(LatLng target) async {
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

  //Write Our data into Delivery Request
  Future<void> writeDriverDataUnderDeliveryRequest(
      SharedProvider sharedProvider, BuildContext context) async {
    loading = true;
    String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("Error while getting driver id");
      return;
    }
    bool dataWritten = await DeliveryRequestService.writeDriverDataOnce(
        deliveryRequestModel!.passengerId,
        sharedProvider.driverCurrentPosition!,
        sharedProvider.driver!);
    if (dataWritten && deliveryRequestPageContext != null) {
      await sharedUtil.makePhoneVibrate();

      deliveryPageIndex = 1;
      markers.clear();
      //Define destination coords\
      LatLng destinationPoint;
      if (deliveryRequestModel!.requestType == RequestType.byCoordinates) {
        destinationPoint = deliveryRequestModel!.information.pickUpCoordinates;
      } else {
        destinationPoint = deliveryRequestModel!.information.currentCoordenates;
      }
      //Update Markers
      markers.add(
        Marker(
          markerId: const MarkerId("pick_up"),
          position: destinationPoint,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      //Start Driver Delivery Status listener
      // listenToDeliveryRequestStatus(
      //      sharedProvider);
      //Update delivery status
      await DeliveryRequestService.updateDeliveryRequestStatus(
          deliveryRequestModel!.passengerId, DeliveryStatus.goingForThePackage);
      //animate camera
      fitMarkers(sharedProvider);
    } else {
      deliveryRequestModel = null;
      //  sharedProvider.passengerInformation = null;
      if (context.mounted) {
        ToastMessageUtil.showToast("Pedido expirado", context);
      }
    }
    loading = false;
  }

  //Show available maps
  void showAvailableMaps(SharedProvider sharedProvider, BuildContext context) {
    if (sharedProvider.driverCurrentPosition == null) {
      return;
    }
    Coords origin = Coords(sharedProvider.driverCurrentPosition!.latitude,
        sharedProvider.driverCurrentPosition!.longitude);
//Open map opctions to navigate
    if (deliveryRequestModel!.requestType == RequestType.byCoordinates) {
      Coords destination = Coords(
          deliveryRequestModel!.information.pickUpCoordinates.latitude,
          deliveryRequestModel!.information.pickUpCoordinates.longitude);
      sharedProvider.showAllAvailableMaps(context, origin, destination);
    } else {
      Coords destinationTemp = Coords(
        deliveryRequestModel!.information.currentCoordenates.latitude,
        deliveryRequestModel!.information.currentCoordenates.longitude,
      );
      sharedProvider.showAllAvailableMaps(context, origin, destinationTemp);
    }
    // if (driverCurrentcoords != null) {
    //   Coords destinationTemp = Coords(
    //       driverCurrentcoords!.latitude, driverCurrentcoords!.longitude);
    //   sharedProvider.showAllAvailableMaps(context, origin, destinationTemp);
    // }
  }

  //Load custom icon
  void loadCustomCarIcon(SharedProvider sharedProvider) async {
    carIcon = await sharedProvider
        .convertImageToBitmapDescriptor("assets/img/taxi.png");
    if (carIcon != null) {
      LatLng currenPosition = LatLng(
          sharedProvider.driverCurrentPosition!.latitude,
          sharedProvider.driverCurrentPosition!.longitude);
      carMarker = Marker(
          markerId: const MarkerId("car_marker"),
          position: currenPosition,
          icon: carIcon!);
    }
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
          if (deliveryRequestModel != null) {
            //get coordinates
            final coords = event.snapshot.value as Map;
            final LatLng driverCoords = LatLng(
                coords['latitude'].toDouble(), coords['longitude'].toDouble());
            //animater camera once
            if (driverCurrentcoords == null) {
              driverCurrentcoords = driverCoords;
              logger.i("");
              //  animateFitCheck(sharedProvider);
            }
            driverCurrentcoords = driverCoords;
            //Draw Polyline
            LatLng destination =
                deliveryRequestModel!.information.dropOffCoordinates;
            if (driverDeliveryStatus == DeliveryStatus.goingForThePackage) {
              destination = deliveryRequestModel!.information.pickUpCoordinates;
            }

            RouteInfo? routeInfo = await SharedService.getRoutePolylinePoints(
                driverCoords, destination, apiKey);
            if (routeInfo != null) {
              polylineFromPickUpToDropOff = Polyline(
                polylineId: const PolylineId(""),
                points: routeInfo.polylinePoints,
                color: Colors.blue,
                width: 5,
              );
            }

            //Update Taxi mark
            if (carIcon != null) {
              carMarker = Marker(
                  markerId: const MarkerId("car_marker"),
                  position: driverCoords,
                  icon: carIcon!);
            }
          }
        }
      });
    } catch (e) {
      logger.e('Error listening to driver coordinates: $e');
    }
  }

  //get route
  Future< RouteInfo?> getRoutePolylines(LatLng driverCoords,LatLng destination)async{
    RouteInfo? routeInfo = await SharedService.getRoutePolylinePoints(
        driverCoords, destination, apiKey);
    return routeInfo;
  }

  //LISTENER: to lsiten value changes under 'delivery_requests/passengerId/status'
  void listenToDeliveryRequestStatus(
      SharedProvider sharedProvider, BuildContext context) {
    if (deliveryRequestModel == null) {
      return;
    }
    String passengerId = deliveryRequestModel!.passengerId;
    final databaseRef =
        FirebaseDatabase.instance.ref('delivery_requests/$passengerId/status');
    try {
      driverStatusListener =
          databaseRef.onValue.listen((DatabaseEvent event) async {
        // Check if the snapshot has data
        if (event.snapshot.exists) {
          // Get the status value

          final status = event.snapshot.value as String;
          switch (status) {
            case DeliveryStatus.goingForThePackage:
              driverDeliveryStatus = DeliveryStatus.goingForThePackage;
              break;
            case DeliveryStatus.haveThePackage:
              driverDeliveryStatus = DeliveryStatus.haveThePackage;
              mapMessages =
                  'El cliente ha sido notificado que haz recogido la encomienda';
              break;
            case DeliveryStatus.goingToTheDeliveryPoint:
              driverDeliveryStatus = DeliveryStatus.goingToTheDeliveryPoint;
              break;
            case DeliveryStatus.arrivedToTheDeliveryPoint:
              driverDeliveryStatus = DeliveryStatus.arrivedToTheDeliveryPoint;
              mapMessages =
                  'El cliente ha sido notificado y esta llegando por su pedido';

              break;
            case DeliveryStatus.passengerHasThePakcage:
              driverDeliveryStatus = DeliveryStatus.passengerHasThePakcage;
              break;
            case DeliveryStatus.canceled:
              driverDeliveryStatus = DeliveryStatus.canceled;
              mapMessages = null;
              if (deliveryRequestModel != null) {
                await DeliveryRequestService.removeDeliveryRequest(
                    deliveryRequestModel!.passengerId);
              }
              deliveryRequestModel = null;
              deliveryPageIndex = 0;
              if (context.mounted) {
                ToastMessageUtil.showToast(
                    "La encomienda ha sido cancelada", context);
              }

              break;
            case DeliveryStatus.finished:
              driverDeliveryStatus = DeliveryStatus.finished;
              mapMessages = null;

              if (deliveryRequestModel != null) {
                await DeliveryRequestService.removeDeliveryRequest(
                    deliveryRequestModel!.passengerId);
              }
              deliveryRequestModel = null;
              deliveryPageIndex = 0;
              if (context.mounted) {
                showStarRatingsBottomSheet(context, passengerId);
              }

              break;
            default:
              logger.e("Driver Status not found..");
              break;
          }
        } else {
          logger.i('Driver $passengerId status does not exist.');
        }
      });
    } catch (e) {
      logger.e('Error listening to driver status: $e');
    }
  }

  //Update 'status' field under 'delivery_requests/driverID/status'
  Future<void> updateDeliveryRequestStatus(
      String status, BuildContext context) async {
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
      await DeliveryRequestService.updateDeliveryRequestStatus(
          deliveryRequestModel!.passengerId, status);
    }
    overlayEntry.remove();
  }
}
