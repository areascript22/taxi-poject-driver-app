import 'package:driver_app/features/delivery_request/view/pages/delivery_page_wrapper.dart';
import 'package:driver_app/features/home/view/widgets/custom_drawer.dart';
import 'package:driver_app/features/home/view/widgets/services_issues_alert.dart';
import 'package:driver_app/features/pending_ride_request/view/pages/pending_ride_request_page.dart';
import 'package:driver_app/features/ride_request/view/pages/ride_request_page.dart';
import 'package:driver_app/features/home/viewmodel/home_view_model.dart';

import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/features/home/view/widgets/custom_toggle_button.dart';
import 'package:driver_app/shared/repositorie/push_notification_service.dart';
import 'package:driver_app/shared/repositorie/track_location_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class DriverApp extends StatefulWidget {
  const DriverApp({super.key});
  @override
  _DriverAppState createState() => _DriverAppState();
}

class _DriverAppState extends State<DriverApp> with WidgetsBindingObserver {
  final logger = Logger();
  late HomeViewModel homeViewModelToDispose;
  final service = FlutterBackgroundService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkGpsPermissions();
//   startForegroundService();
  }

  void startForegroundService() async {
    await startBackgroundService();
  }
  //Try to get Device Token For Push notification

  //Check all location permissions
  void checkGpsPermissions() async {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    homeViewModelToDispose = homeViewModel;

    // homeViewModel.startForegroundTask();
    homeViewModel.listenToDeliveryRequests(
        FirebaseDatabase.instance.ref('delivery_requests'));
    homeViewModel.listenToPendingRideRequests(
        FirebaseDatabase.instance.ref('driver_requests'));
    homeViewModel.listenToRequestAssigned();
    bool gpsPermissions =
        await homeViewModel.checkGpsPermissions(sharedProvider);
    homeViewModel.listenToLocationServicesAtSystemLevel();
    sharedProvider.isGPSPermissionsEnabled = gpsPermissions;
    //  homeViewModel.startLocationTracking(sharedProvider);
    homeViewModel.initializeNotifications(sharedProvider);
    homeViewModel.listenToInternetConnection();

    listenToBackgroundMessages();
    await PushNotificationService.initializeNotificationChannel();
    await PushNotificationService.requestPermission();
  }

  @override
  void dispose() {
    homeViewModelToDispose.clearListeners();
    service.invoke('stopService');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    return Scaffold(
      key: sharedProvider.driverAppScaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 40,
        title: CustomToggleButton(
          onToggle: (bool isOnline) {},
        ),
        bottom: homeViewModel.getIssueBassedOnPriority() != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60.0),
                child: ServicesIssueAlert(
                  dataMap: homeViewModel.getIssueBassedOnPriority()!,
                ),
              )
            : null,
      ),
      drawer: const CustomDrawer(),
      body: Stack(children: [
        //Content
        IndexedStack(
          index: homeViewModel.currentPageIndex,
          children: const [
            // PermissionsPage(),
            RideMRequestPage(),
            PendingRideRequestPage(),
            //DeliveryRequestPage(),
            DeliveryPageWrapper(),
          ],
        ),
      ]),
      bottomNavigationBar: homeViewModel.locationPermissionsSystemLevel
          ? BottomNavigationBar(
              currentIndex: homeViewModel.currentPageIndex,
              onTap: (index) {
                logger.i("Changing index to $index");
                homeViewModel.currentPageIndex = index;
              },
              items: [
                //Map icon
                const BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Mapa',
                ),

                //pendin taxi requests
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(Icons.taxi_alert),
                      ),
                      if (homeViewModel.pendingRequestLength > 0)
                        Positioned(
                          right: 0,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              homeViewModel.pendingRequestLength.toString(),
                              style: const TextStyle(
                                color: Colors.white, // Text color
                                fontSize: 10, // Font size for the count
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Pendientes',
                ),

                //Shpping cart icon
                BottomNavigationBarItem(
                  icon: Stack(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(Icons.shopping_cart),
                      ),
                      if (homeViewModel.deliveryRequestLength > 0)
                        Positioned(
                          right: 0,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              homeViewModel.deliveryRequestLength.toString(),
                              style: const TextStyle(
                                color: Colors.white, // Text color
                                fontSize: 10, // Font size for the count
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Órdenes',
                ),
              ],
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
            )
          : const SizedBox(),
    );
  }
}
