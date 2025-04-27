import 'package:driver_app/features/home/repository/home_service.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/models/passenger_request.dart';
import 'package:driver_app/shared/repositorie/shared_service.dart';
import 'package:driver_app/shared/widgets/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:image/image.dart' as img;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SharedProvider extends ChangeNotifier {
  //Driver? driverModel; //To user PassengerModel data across multiple Features
  final logger = Logger();
  final GlobalKey<ScaffoldState> driverAppScaffoldKey =
      GlobalKey<ScaffoldState>();
  GUser? driver;
  bool isGPSPermissionsEnabled = false;
  Position? driverCurrentPosition;
  String? rideRequestmodel;
  bool isThereInternetConnection = true;

  String? currentDeviceToken; //For Push notifications
  String availavilityState = Availability.offline;

  //To DISPLAY AND HIDE DELIVERY AND RIDE REQEUSTS
  String _driverRideStatus = DriverRideStatus.pending;
  static String driverRideStatusS = DriverRideStatus.pending;
  PassengerRequest? secondPassenger;
  bool isTherePassengerInTheWay = false;
  String version = '';
  String sector = 'n/a';
  BitmapDescriptor? taxiIcon;

//  GETTERS
  String get driverRideStatus => _driverRideStatus;
//SETTERS
  set driverRideStatus(String value) {
    _driverRideStatus = value;
    SharedProvider.driverRideStatusS = value;
  }

  //CONTRUCTOR
  SharedProvider() {
    _loadVersion();
  }
  //BOTTOM SHEET: It displays all available maps
  Future<void> showAllAvailableMaps(
      BuildContext context, Coords origin, Coords destination) async {
    //Get all maps installed
    //  final availableMaps = await MapLauncher.installedMaps;
    if (!context.mounted) {
      return;
    }

    //  Navigator.pop(context); // Close bottom sheet
    try {
      final Uri url = Uri.parse(
          "google.navigation:q=${destination.latitude},${destination.longitude}&mode=d");

      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        logger.e('Could not open Google Maps.');
      }
    } catch (e) {
      logger.e("Error tryin to open the map: $e");
    }

    //Show all map apps options
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   builder: (context) {
    //     return SingleChildScrollView(
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         mainAxisSize: MainAxisSize.min,
    //         children: <Widget>[
    //           //title
    //           const SizedBox(height: 15),
    //           //List of available maps
    //           ListView.builder(
    //             shrinkWrap: true,
    //             physics:
    //                 const NeverScrollableScrollPhysics(), // Disable internal scrolling
    //             itemCount: availableMaps
    //                 .length, // Adjust this number based on your data
    //             itemBuilder: (context, index) {
    //               return ListTile(
    //                 onTap: () async {
    //                   // availableMaps[index].showMarker(
    //                   //     coords: destination, title: "Destination");

    //                   Navigator.pop(context); // Close bottom sheet
    //                   final Uri url = Uri.parse(
    //                       "google.navigation:q=${destination.latitude},${destination.longitude}&mode=d");

    //                   if (await canLaunchUrl(url)) {
    //                     await launchUrl(url);
    //                   } else {
    //                     throw 'Could not open Google Maps.';
    //                   }
    //                   // await availableMaps[index].showDirections(
    //                   //   destination: destination,
    //                   //   origin: origin, // User's current location
    //                   //   directionsMode: DirectionsMode
    //                   //       .driving, // Change to walking/biking if needed
    //                   // );
    //                 },
    //                 leading: SvgPicture.asset(
    //                   availableMaps[index].icon, // Path to the SVG icon
    //                   width: 40.0,
    //                   height: 40.0,
    //                 ),
    //                 title: Text(
    //                     availableMaps[index].mapName), // Your item content here
    //               );
    //             },
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );
  }

  //Open an map without passing th destination coords
  Future<void> showAllAvailableMapsWithoutDestination(
      BuildContext context) async {
    // Get all installed maps
    final availableMaps = await MapLauncher.installedMaps;

    if (!context.mounted) {
      return;
    }

    // Show a bottom sheet with the list of map apps
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 15),
              // List of available maps
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable internal scrolling
                itemCount: availableMaps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      availableMaps[index].showMarker(
                        title: '',
                        coords: Coords(0, 0), // No destination point
                      );
                    },
                    leading: SvgPicture.asset(
                      availableMaps[index].icon, // Path to the SVG icon
                      width: 40.0,
                      height: 40.0,
                    ),
                    title: Text(availableMaps[index].mapName),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //Convert an image from asset into BitmapDescription
  Future<BitmapDescriptor?> convertImageToBitmapDescriptor(String path) async {
    try {
      final ByteData byteData = await rootBundle.load(path);
      final Uint8List bytes = byteData.buffer.asUint8List();
      img.Image originalImage = img.decodeImage(bytes)!;
      img.Image resizedImage =
          img.copyResize(originalImage, width: 100, height: 100);
      final Uint8List resizedBytes =
          Uint8List.fromList(img.encodePng(resizedImage));
      final BitmapDescriptor icon = BitmapDescriptor.fromBytes(resizedBytes);
      return icon;
    } catch (e) {
      return null;
    }
  }

  //save passanger rating and comments
  Future<void> saveRatingAndComments(double newRating, String passengerId,
      String comment, BuildContext context) async {
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => const LoadingOverlay(),
    );
    overlay.insert(overlayEntry);

    ///
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) return;
    await SharedService.updateDriverRating(newRating, passengerId);
    if (comment.isNotEmpty) {
      await SharedService.addDriverComment(driverId, passengerId, comment);
    }

    ///
    overlayEntry.remove();
  }

  //To load current vertion
  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
    notifyListeners();
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
        final udaSuccess = await SharedService.updateDriverAvailability(
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
}
