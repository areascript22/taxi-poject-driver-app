import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/repositorie/push_notification_service.dart';
import 'package:driver_app/shared/utils/configuration_file.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:logger/web.dart';

class HomeService {
  static Logger logger = Logger();
  //Write initial Driver info
  static Future<bool> writeInitialDriverInfo(
      SharedProvider sharedProvider) async {
    final Logger logger = Logger();
    final currentLocation = sharedProvider.driverCurrentPosition;
    if (currentLocation == null) {
      logger.e("NO current location available");
      return false;
    }
    try {
      //get current location

      GUser driver = sharedProvider.driver!;
      // Get the authenticated driver's ID
      String? driverId = FirebaseAuth.instance.currentUser!.uid;
      // Reference to the driver's node in Firebase
      final DatabaseReference databaseRef =
          FirebaseDatabase.instance.ref().child('drivers/$driverId');
      //Get Device Token
      String? deviceToken = await PushNotificationService.getDeviceToken().timeout(ConfigF.timeOut);
      // Write the initial full data
      Map<String, dynamic> driverData = {
        "availability": Availability.online,
        "status": DriverRideStatus.pending,
        "status_availability":
            "${DriverRideStatus.pending}_${Availability.online}",
        //  "duration": "NA",
        "information": {
          "deviceToken": deviceToken ?? '',
          "name": driver.name,
          "rating": driver.ratings.totalRatingScore,
          "phone": driver.phone,
          "vehicleModel": driver.vehicle!.model,
          "profilePicture": driver.profilePicture,
          "carRegistrationNumber": driver.vehicle!.carRegistrationNumber,
          "taxiCode": driver.vehicle!.taxiCode,
        },
        'location': {
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
        }
      };
      await databaseRef.update(driverData).timeout(ConfigF.timeOut);
      logger.i("Initial data written to Firebase");
      return true;
    } catch (e) {
      logger.e("Error writing/updating location in Firebase: $e");
      return false;
    }
  }

  // //Update Location in Firebase
  // static Future<void> updateDriverCurrentLocationInFirebase(
  //     Position position) async {
  //   final Logger logger = Logger();
  //   try {
  //     // Get the authenticated driver's ID
  //     String? driverId = FirebaseAuth.instance.currentUser?.uid;
  //     if (driverId == null) {
  //       logger.i("User is not authenticated");
  //       return;
  //     }
  //     // Reference to the driver's node in Firebase
  //     final DatabaseReference databaseRef =
  //         FirebaseDatabase.instance.ref().child('drivers/$driverId');
  //     // Update only the location field
  //     Map<String, dynamic> locationData = {
  //       "location": {
  //         "latitude": position.latitude,
  //         "longitude": position.longitude,
  //       },
  //     };
  //     await databaseRef.update(locationData);
  //     // logger.i(
  //     //     "Location updated in Firebase: ${position.latitude}, ${position.longitude}");
  //   } catch (e) {
  //     logger.e("Error writing/updating location in Firebase: $e");
  //   }
  // }

  // Function to write location to Firebase
  static Future<void> writeOrUpdateLocationInFirebase(
      Position position, GUser driver) async {
    final Logger logger = Logger();
    try {
      // Get the authenticated driver's ID
      String? driverId = FirebaseAuth.instance.currentUser?.uid;
      if (driverId == null) {
        logger.i("User is not authenticated");
        return;
      }

      // Reference to the driver's node in Firebase
      final DatabaseReference databaseRef =
          FirebaseDatabase.instance.ref().child('drivers/$driverId');

      // Check if the data already exists in Firebase
      DataSnapshot snapshot = await databaseRef.get();
      if (!snapshot.exists) {
        //Get Device Token
        String? deviceToken = await PushNotificationService.getDeviceToken();

        // Write the initial full data
        Map<String, dynamic> driverData = {
          "availability": Availability.offline,
          "status": "pending",
          "status_availability": "pending_${Availability.offline}",
          //  "duration": "NA",
          "information": {
            "deviceToken": deviceToken ?? '',
            "name": driver.name,
            "rating": driver.ratings.totalRatingScore,
            "phone": driver.phone,
            "vehicleModel": driver.vehicle!.model,
            "profilePicture": driver.profilePicture,
            "carRegistrationNumber": driver.vehicle!.carRegistrationNumber,
            "taxiCode": driver.vehicle!.taxiCode,
          },
          "location": {
            "latitude": position.latitude,
            "longitude": position.longitude,
          },
        };

        await databaseRef.set(driverData);
        logger.i("Initial data written to Firebase");
      } else {
        // Update only the location field
        Map<String, dynamic> locationData = {
          "location": {
            "latitude": position.latitude,
            "longitude": position.longitude,
          },
        };

        await databaseRef.update(locationData);
        //   logger.i(
        //       "Location updated in Firebase: ${position.latitude}, ${position.longitude}");
        //
      }
    } catch (e) {
      logger.e("Error writing/updating location in Firebase: $e");
    }
  }

  //To handler disconection from Datbase

  // static Future<void> setOnDisconnectHandler() async {
  //   try {
  //     String? driverId = FirebaseAuth.instance.currentUser?.uid;
  //     if (driverId == null) return;
  //     //Reference to "drivers" node
  //     final DatabaseReference databaseRef =
  //         FirebaseDatabase.instance.ref().child('drivers/$driverId');
  //     //Reference to "positions" node
  //     final DatabaseReference positionReference =
  //         FirebaseDatabase.instance.ref().child('positions/$driverId');

  //     // Schedule removal of location data when the app disconnects
  //     await databaseRef.onDisconnect().remove();

  //     await positionReference.onDisconnect().remove();
  //     Logger().i("onDisconnect handler set for driverId: $driverId");
  //   } catch (e) {
  //     Logger().e("Error setting onDisconnect handler: $e");
  //   }
  // }

  //Update device token in Firestore
  static Future<void> updateDeviceToken(String deviceToken) async {
    final logger = Logger();
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('g_user').doc(userId).update({
        'deviceToken': deviceToken,
      });
      logger.i("Device token updated successfully.");
    } catch (e) {
      logger.e("Error updating device token: $e");
    }
  }

  //
  static Future<void> updateDeviceTokenInFRD(String newToken) async {
    final logger = Logger();
    try {
      String? driverId = FirebaseAuth.instance.currentUser?.uid;
      if (driverId == null) {
        logger.e("User not autenticated");
        return;
      }
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("drivers/$driverId/information");

      await ref.update({
        "deviceToken": newToken,
      });

      logger.i("Device token updated successfully!");
    } catch (e) {
      logger.e("Error updating device token: $e");
    }
  }

  //Update Availability status
  static Future<bool> updateDriverAvailability(
      String availability, String driverRideStatus) async {
    final logger = Logger();
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    try {
      String driverId = FirebaseAuth.instance.currentUser!.uid;
      await database.child('drivers/$driverId').update({
        'availability': availability,
        'status_availability': "${driverRideStatus}_$availability",
      }).timeout(ConfigF.timeOut);
      logger.i("Driver availability updated successfully.");
      return true;
    } catch (e) {
      logger.e("Error updating availability: $e");
      return false;
    }
  }

  //Go Offline
  // static Future<bool> goOffline() async {
  //   try {
  //     final driverId = FirebaseAuth.instance.currentUser!.uid;

  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }
}
