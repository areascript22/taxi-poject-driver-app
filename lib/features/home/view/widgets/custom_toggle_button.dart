import 'package:driver_app/features/home/viewmodel/home_view_model.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/repositorie/local_stogare_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class CustomToggleButton extends StatefulWidget {
  final Function(bool) onToggle;

  const CustomToggleButton({super.key, required this.onToggle});

  @override
  _CustomToggleButtonState createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  bool isOnline = false; // Initial state
  bool isThereLocalData = false;
  final service = FlutterBackgroundService();
  final logger = Logger();

  @override
  void initState() {
    super.initState();

    checkIsThereLocalData();
  }

  //CHECK IF IS LOCAL DATA
  void checkIsThereLocalData() {
    isThereLocalData = LocalStorageService.getIsThereDataInDB();

  }

  void toggle(
      HomeViewModel homeViewModel, SharedProvider sharedProvider) async {
    if (isOnline) {
      //STOP FOREGROUND SERVICES
      final bool response = await homeViewModel.goOnlineOrOffline(
          Availability.offline,
          sharedProvider.driverRideStatus,
          sharedProvider);

      if (response) {
        sharedProvider.availavilityState = Availability.offline;
        service.invoke('stopService');
        await LocalStorageService.saveIsThereDataInDB(false);
        isThereLocalData = false;
      }
    } else {
      final bool response = await homeViewModel.goOnlineOrOffline(
          Availability.online, sharedProvider.driverRideStatus, sharedProvider);

      if (response) {
        sharedProvider.availavilityState = Availability.online;
        await service.startService();
        service.invoke('setAsForeground'); // Switch to Foreground
        await LocalStorageService.saveIsThereDataInDB(true);
        isThereLocalData = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    final driverId = FirebaseAuth.instance.currentUser?.uid;

    if (driverId == null) {
      return const Text("Error: Usuario no autenticado.");
    }
    final dbRef = FirebaseDatabase.instance.ref('drivers/$driverId');
    dbRef.get;
    return GestureDetector(
      onTap: () => toggle(homeViewModel, sharedProvider),
      child: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (homeViewModel.isThereInternetConnection) {
            if (snapshot.data != null &&
                snapshot.data?.snapshot.value != null) {
              isOnline = true;
            } else {
              isOnline = false;
            }
          } else {
            isOnline = isThereLocalData;
          }

          if (!homeViewModel.locationPermissionUserLevel ||
              !homeViewModel.locationPermissionsSystemLevel ||
              !homeViewModel.isCurrentLocationAvailable) {
            return const SizedBox();
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 120,
            height: 35,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
                  width: 2),
            ),
            child: Stack(
              children: [
                Align(
                  alignment:
                      isOnline ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      width: 60,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isOnline ? "Disponible" : "Ocupado",
                        style: TextStyle(
                          color: isOnline ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
