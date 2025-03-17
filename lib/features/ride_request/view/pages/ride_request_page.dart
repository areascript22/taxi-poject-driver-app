import 'dart:async';
import 'package:driver_app/features/ride_request/view/widgets/bottom_sheet_cancel_ride.dart';
import 'package:driver_app/features/ride_request/view/widgets/driver_queue.dart';
import 'package:driver_app/features/ride_request/view/widgets/passenger_info_card.dart';
import 'package:driver_app/features/ride_request/view/widgets/second_passenger_tile.dart';
import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/widgets/coundown_timer.dart';
import 'package:driver_app/shared/widgets/custom_circular_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class RideMRequestPage extends StatefulWidget {
  const RideMRequestPage({super.key});

  @override
  State<RideMRequestPage> createState() => _RideMRequestPageState();
}

class _RideMRequestPageState extends State<RideMRequestPage> {
  final logger = Logger();
  late RideRequestViewModel providerToDispose;
  String _mapStyle = "";

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() {
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    final rideRequestViewModel =
        Provider.of<RideRequestViewModel>(context, listen: false);
    providerToDispose = rideRequestViewModel;
    rideRequestViewModel.listenToDriverCoordenatesInFirebase(sharedProvider);
    rideRequestViewModel.listenerToPassengerRequest(sharedProvider);
    rideRequestViewModel.listenToSecondPassangerRequest(sharedProvider);
    rideRequestViewModel.listenToDriverStatus(sharedProvider, context);
    rideRequestViewModel.loadIcons();
    rideRequestViewModel.listenToAllDriversPositions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateMapStyle();
  }

  @override
  void dispose() {
    providerToDispose.cancelListeners();
    providerToDispose.mapController = Completer();
    super.dispose();
  }

  //Update map Style
  Future<void> updateMapStyle() async {
    Brightness newBrightness = MediaQuery.of(context).platformBrightness;
    //  final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    String stylePath = newBrightness == Brightness.dark
        ? 'assets/json/dark_map_style.json'
        : 'assets/json/light_map_style.json';

    String style = await rootBundle.loadString(stylePath);
    setState(() {
      _mapStyle = style;
    });
    if (providerToDispose.mapController.isCompleted) {
      GoogleMapController controller =
          await providerToDispose.mapController.future;
      controller.setMapStyle(_mapStyle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    rideRequestViewModel.rideRequestPageContext = context;
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              showCancelRideBottomSheet(context);
            },
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        toolbarHeight:
            rideRequestViewModel.passengerInformation == null ? 0 : 40,
        bottom: rideRequestViewModel.secondPassenger != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(100.0),
                child: SecondPassengerTile(
                    secondPassengerInfo:
                        rideRequestViewModel.secondPassenger!.information),
              )
            : null,
      ),
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          //Map
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            initialCameraPosition: const CameraPosition(
              target: LatLng(-1.648920, -78.677108),
              zoom: 14,
            ),
            markers: {
              ...rideRequestViewModel.markers,
              rideRequestViewModel.taxiMarker ??
                  const Marker(markerId: MarkerId("test")),
              ...rideRequestViewModel.driversMarkers.values.toSet(),
            },
            polylines: {rideRequestViewModel.polylineFromPickUpToDropOff},
            onMapCreated: (controller) {
              rideRequestViewModel.onMapCreated(controller);
              if (!rideRequestViewModel.mapController.isCompleted) {
                updateMapStyle();
              }
            },
          ),

          //TEST BUTTON
          // Positioned(
          //   top: 5,
          //   right: 100,
          //   child: CustomCircularButton(
          //     onPressed: () async {
          //       await PushNotificationService.sendPushNotification(
          //           deviceToken:
          //               'fbggI3L-ROyV7YEDEfN6yC:APA91bFle4Xg_0XXGkVD5hjpe3BkREU_deVz1AI71c6XwKYCUEiBsw5UBwFuWoOg0ZMBB0AhDWu70Z7hXacHGKtgNdhAG_7MSOBgGy7Yg-V6k-3XIxX5uoc',
          //           title: "asdf",
          //           body: "test");
          //     },
          //     icon: const Icon(Icons.navigation_rounded),
          //   ),
          // ),

          //BUTTON: Menu
          if (rideRequestViewModel.passengerInformation == null)
            Positioned(
              top: 5,
              left: 10,
              child: CustomCircularButton(
                onPressed: () {
                  print("asdf");
                  sharedProvider.driverAppScaffoldKey.currentState
                      ?.openDrawer();
                },
                icon: const Icon(Ionicons.menu_outline),
              ),
            ),
          //Button
          //BUTTON: Select Position Taxi
          //  if (rideRequestViewModel.driverRideStatus == DriverRideStatus.pending)
          // Positioned(
          //   top: 5,
          //   right: 210,
          //   child: CustomCircularButton(
          //     icon: const Icon(Ionicons.person),
          //     onPressed: () {
          //       RideRequestService.bookDriverPositionInQueueTest(
          //           idUsuario: "driver_1");
          //     },
          //   ),
          // ),
          //COUNTDOWN timer
          if (rideRequestViewModel.routeDuration != null)
            Positioned(
              top: 5,
              child: CountdownTimer(
                minutes: rideRequestViewModel.routeDuration!,
              ),
            ),

          //BUTTON: Book position in queue and see our current position
          if (rideRequestViewModel.driverRideStatus == DriverRideStatus.pending)
            Positioned(
              top: 5,
              right: 80,
              child: CustomCircularButton(
                icon: StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child('positions')
                      .onValue,
                  builder: (context, snapshot) {
                    // if (snapshot.connectionState == ConnectionState.waiting) {
                    //   return const CircularProgressIndicator(
                    //     color: Colors.blue,
                    //   );
                    // }
                    if (!snapshot.hasData || snapshot.hasError) {
                      return const Icon(Icons.error, color: Colors.red);
                    }
                    if (snapshot.data!.snapshot.value == null) {
                      return const Icon(Ionicons.create_outline);
                    }

                    // Parse positions data
                    final Map<dynamic, dynamic> positions =
                        snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                    // Since push keys are inherently ordered by timestamp, we can just
                    // iterate through the keys to get the order without sorting by timestamp.

                    // Get the driver ID and order based on the push key order
                    List<MapEntry<String, dynamic>> driverPositions = [];
                    positions.forEach((driverId, driverData) {
                      driverPositions.add(MapEntry(driverId, driverData));
                    });
                    //  logger.f("driver Positions: ${driverPositions}");
                    driverPositions.sort((a, b) => a.key.compareTo(b.key));

                    // Since Firebase stores push keys in time order, the order of keys is already
                    // sorted from the oldest to the newest. We can simply find the driver's order.
                    int order = driverPositions.indexWhere((entry) =>
                            entry.value['driver_id'] ==
                            sharedProvider.driver!.id) +
                        1;

                    return Text(order.toString());
                  },
                ),
                onPressed: () async {
                  int? response = await showDriverQueueDialog(context);
                  if (response != null) {
                    rideRequestViewModel.currenQueuePoosition = response;
                  }
                },
              ),
            ),

          //BUTTON: animate camera to current lcoation
          if (rideRequestViewModel.passengerInformation == null)
            Positioned(
              top: 5,
              right: 10,
              child: CustomCircularButton(
                onPressed: () async {
                  //animate camera
                  if (sharedProvider.driverCurrentPosition != null) {
                    LatLng target = LatLng(
                        sharedProvider.driverCurrentPosition!.latitude,
                        sharedProvider.driverCurrentPosition!.longitude);
                    await rideRequestViewModel.animateToLocation(target);
                  }
                },
                icon: const Icon(Icons.navigation_rounded),
              ),
            ),

          // Positioned(
          //   top: 5,
          //   right: 170,
          //   child: CustomCircularButton(
          //     onPressed: () async {
          //       //animate camera
          //       await rideRequestViewModel.fitMarkers(sharedProvider);
          //     },
          //     icon: const Icon(Icons.navigation_rounded),
          //   ),
          // ),

          //CARD: Pasenger info such as Image, name, ratings.
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child:
                //Passenger info
                PassengerInfoCard(),
          ),

          //ADMIN: BUTTON: Show all online drivers.
          // if (sharedProvider.driver!.role.contains(Roles.admin))
          //   Positioned(
          //     top: 5,
          //     right: 150,
          //     child: CustomCircularButton(
          //       icon: const Icon(Ionicons.person),
          //       onPressed: () {
          //         showDriversDialog(context);
          //       },
          //     ),
          //   ),
        ],
      ),
    );
  }
}
