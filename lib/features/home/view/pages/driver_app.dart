import 'package:driver_app/features/delivery_request/view/pages/delivery_page_wrapper.dart';
import 'package:driver_app/features/home/view/widgets/custom_drawer.dart';
import 'package:driver_app/features/home/view/widgets/services_issues_alert.dart';
import 'package:driver_app/features/pending_ride_request/view/pages/pending_ride_request_page.dart';
import 'package:driver_app/features/ride_request/view/pages/ride_request_page.dart';
import 'package:driver_app/features/home/viewmodel/home_view_model.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/features/home/view/widgets/custom_toggle_button.dart';
import 'package:driver_app/shared/providers/shared_updater.dart';
import 'package:driver_app/shared/repositorie/push_notification_service.dart';
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

  //Check all location permissions
  void checkGpsPermissions() async {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    final sharedUpdater = Provider.of<SharedUpdater>(context, listen: false);
    homeViewModelToDispose = homeViewModel;

    // homeViewModel.startForegroundTask();
    homeViewModel.listenToDeliveryRequests(
        FirebaseDatabase.instance.ref('delivery_requests'), sharedProvider);
    homeViewModel.listenToPendingRideRequests(
        FirebaseDatabase.instance.ref('driver_requests'), sharedProvider);
    homeViewModel.listenToRequestAssigned(sharedProvider);
    bool gpsPermissions =
        await homeViewModel.checkGpsPermissions(sharedProvider);
    homeViewModel.listenToLocationServicesAtSystemLevel();
    sharedProvider.isGPSPermissionsEnabled = gpsPermissions;
    //  homeViewModel.startLocationTracking(sharedProvider);
    homeViewModel.initializeNotifications(sharedProvider);
    homeViewModel.listenToInternetConnection(sharedProvider);
    homeViewModel.listenToEmergencyNotifications(sharedUpdater);

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
    final sharedUpdater = Provider.of<SharedUpdater>(context);
    return Scaffold(
      key: sharedProvider.driverAppScaffoldKey,
      appBar: AppBar(
        backgroundColor: homeViewModel.getIssueBassedOnPriority()?['color'],
        automaticallyImplyLeading: false,
        toolbarHeight: homeViewModel.isThereAnyIssue() ? 0 : 40,
        title: homeViewModel.isThereAnyIssue()
            ? const SizedBox()
            : const CustomToggleButton(),
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
      body: Column(
        children: [
          //Emergency banner
          if (sharedUpdater.weAreInDanger)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFFFACD),
                    size: 35,
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        "Todos los conductores recibieron tu notificación de emergencia.",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFFACD)),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => homeViewModel
                        .cancelEmergencyNotificatino(sharedUpdater),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          //pages
          Expanded(
            child: Stack(children: [
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
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: homeViewModel.loading
      //       ? null
      //       : () => homeViewModel.sendEmergencyNotify(sharedProvider, context),
      //   backgroundColor:
      //       homeViewModel.weAreInDanger ? Colors.red[300] : Colors.green[300],
      //   child: homeViewModel.loading
      //       ? const CircularProgressIndicator()
      //       : const Icon(
      //           Icons.warning_amber_rounded,
      //           color: Colors.white,
      //           size: 35,
      //         ),
      // ),
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
              selectedItemColor: Colors.purple,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
            )
          : const SizedBox(),
    );
  }
}
